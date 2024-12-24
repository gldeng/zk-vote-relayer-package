zk_vote_relayer_dbmigrator_module = import_module("/dbmigrator.star")
zk_vote_relayer_api_module = import_module("/api.star")
zk_vote_relayer_silo_module = import_module("/silo.star")


def run(plan, advertised_ip, mongodb_url, redis_url, aelf_node_url):
    zk_vote_relayer_dbmigrator_module.run(
        plan, 
        mongodb_url=mongodb_url, 
        redis_url=redis_url
    )
    zk_vote_relayer_silo_module.run(
        plan, 
        advertised_ip,
        mongodb_url=mongodb_url, 
        redis_url=redis_url, 
        aelf_node_url=aelf_node_url
    )

    api_url = zk_vote_relayer_api_module.run(
        plan, 
        mongodb_url=mongodb_url, 
        redis_url=redis_url
    )

    return {
        "zk_vote_relayer_api_url": api_url
    }