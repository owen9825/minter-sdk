#include "../../../fa2/fa2_interface.mligo"
#include "../nft/fa2_multi_nft_manager.mligo"
#include "../nft/fa2_multi_nft_asset_multi_admin.mligo"

type mint_edition_run = 
[@layout:comb]
{
    edition_info : ((string, bytes) map);
    number_of_editions : nat;
}

type distribute_edition = 
[@layout:comb] 
{
    edition_id : nat; 
    receivers : address list;
}

type editions_entrypoints = 
 | FA2 of nft_asset_entrypoints
 | Mint_editions of mint_edition_run list
 | Distribute_editions of distribute_edition list

type edition_metadata =
[@layout:comb]
  {   
      creator : address;
      edition_info: ((string, bytes) map);
      initial_token_id : nat;
      number_of_editions : nat;
      number_of_editions_to_distribute : int;
  }

type editions_metadata = (nat, edition_metadata) big_map

type editions_storage = 
{   
    current_edition_id : nat; 
    editions_metadata : editions_metadata;
    nft_asset_storage : nft_asset_storage;
}

let address_list_pop (addresses : address list) : (address * address list) option =
  ([%Michelson ({| { IF_CONS {PAIR; SOME;} {NONE (pair address (list address))} } |} : address list -> (address * address list) option)] addresses : (address * address list) option)

let distribute_list_pop (distribute_list: distribute_edition list) : (distribute_edition * distribute_edition list) option =
  ([%Michelson ({| { IF_CONS {PAIR; SOME;} {NONE (pair (pair nat (list address)) (list (pair nat (list address))))} } |} : distribute_edition list -> (distribute_edition * distribute_edition list) option)] distribute_list : (distribute_edition * distribute_edition list) option)

let mint_list_pop (editions_list : mint_edition_run list) : (mint_edition_run * mint_edition_run list) option =
  ([%Michelson ({| { IF_CONS {PAIR; SOME;} {NONE (pair (pair (map string bytes) nat) (list (pair (map string bytes) nat)))} } |} : mint_edition_run list -> (mint_edition_run * mint_edition_run list) option)] editions_list : (mint_edition_run * mint_edition_run  list) option)

let rec mint_editions ( editions_list , storage : mint_edition_run list * editions_storage)
  : operation list * editions_storage =
  let mint_single_edition_run : (mint_edition_run * editions_storage) -> editions_storage = fun (param, storage : mint_edition_run * editions_storage) ->  
    let edition_metadata : edition_metadata = {
      creator = Tezos.sender;
      edition_info = param.edition_info;
      initial_token_id = storage.nft_asset_storage.assets.next_token_id;
      number_of_editions = param.number_of_editions;
      number_of_editions_to_distribute = int(param.number_of_editions) 
    } in
    let new_editions_metadata = Big_map.add storage.current_edition_id edition_metadata storage.editions_metadata in
    let new_asset_storage = {storage.nft_asset_storage.assets with next_token_id = storage.nft_asset_storage.assets.next_token_id + param.number_of_editions} in 
    {storage with 
        current_edition_id = storage.current_edition_id + 1n;
        editions_metadata = new_editions_metadata; 
        nft_asset_storage = {storage.nft_asset_storage with assets = new_asset_storage}
    } in
  (match (mint_list_pop editions_list) with 
    | Some popped_pair -> 
        let (edition_run, remaining_editions) = popped_pair in
        let new_storage = mint_single_edition_run(edition_run, storage) in 
        mint_editions (remaining_editions, new_storage)
    | None -> ([] : operation list), storage)

let distribute_edition_to_address (edition_metadata, to_, token_id, storage : edition_metadata * address * nat * editions_storage) 
  : editions_storage * edition_metadata = 
  let new_edition_metadata = {edition_metadata with number_of_editions_to_distribute = edition_metadata.number_of_editions_to_distribute - 1} in
  let mint_edition_param : mint_edition_param = {
      token_id = token_id; 
      owner = to_;
  } in
  let _ , nft_token_storage = mint_edition (mint_edition_param, storage.nft_asset_storage.assets) in
  {storage with nft_asset_storage = {storage.nft_asset_storage with assets = nft_token_storage}}, new_edition_metadata

let rec distribute_edition_to_addresses ( receivers, edition_metadata, token_id, storage : (address list) * edition_metadata * nat * editions_storage)
  : editions_storage * edition_metadata = 
  match (address_list_pop (receivers)) with 
    | Some popped_pair -> 
       let (to_, remaining_receivers) = popped_pair in 
       let new_storage, new_edition_metadata = distribute_edition_to_address (edition_metadata, to_, token_id, storage) in 
       distribute_edition_to_addresses (remaining_receivers, new_edition_metadata, token_id + 1n, new_storage)
    | None -> 
        if (edition_metadata.number_of_editions_to_distribute < 0) then 
             (failwith "NO_EDITIONS_TO_DISTRIBUTE" : editions_storage * edition_metadata) else 
             storage, edition_metadata 

let rec distribute_editions (distribute_list, storage : distribute_edition list * editions_storage)
  : operation list * editions_storage =
  match (distribute_list_pop distribute_list) with 
    | Some popped_pair ->
        let (distribute_param, remaining_distributions) = popped_pair in
        let edition_metadata : edition_metadata = (match (Big_map.find_opt distribute_param.edition_id storage.editions_metadata) with 
          | Some edition_metadata -> edition_metadata 
          | None -> (failwith "INVALID_EDITION_ID" : edition_metadata)) in 
        let token_id = edition_metadata.initial_token_id + abs (edition_metadata.number_of_editions - edition_metadata.number_of_editions_to_distribute) in 
        let new_editions_storage, new_edition_metadata = distribute_edition_to_addresses(distribute_param.receivers, edition_metadata, token_id, storage) in
        let new_editions_metadata = Big_map.update distribute_param.edition_id (Some new_edition_metadata) new_editions_storage.editions_metadata in
        let new_storage = {new_editions_storage with editions_metadata = new_editions_metadata} in 
        (distribute_editions (remaining_distributions, new_storage))
    | None -> ([] : operation list), storage 

let editions_main (param, editions_storage : editions_entrypoints * editions_storage)
    : (operation  list) * editions_storage =
    match param with 
    | FA2 nft_asset_entrypoints -> 
        let ops, new_nft_asset_storage = nft_asset_main (nft_asset_entrypoints, editions_storage.nft_asset_storage) in
        ops, {editions_storage with nft_asset_storage = new_nft_asset_storage}
    | Mint_editions mint_param -> 
        let u : unit = fail_if_not_admin editions_storage.nft_asset_storage.admin in
        let u = fail_if_paused editions_storage.nft_asset_storage.admin in
        (mint_editions (mint_param, editions_storage))
    | Distribute_editions distribute_param -> 
        let u : unit = fail_if_paused editions_storage.nft_asset_storage.admin in
        (distribute_editions (distribute_param, editions_storage))