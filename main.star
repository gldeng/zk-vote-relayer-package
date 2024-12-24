aelf_infra_module = import_module("github.com/gldeng/aelf-infra-package/main.star")
aelf_node_module = import_module("github.com/gldeng/aelf-node-package/aelf_node.star")
zk_vote_relayer_module = import_module("/zkvoterelayer.star")

def run(plan, advertised_ip):
    output = {}
    aelf_infra_output = aelf_infra_module.run(
        plan,
        need_mongodb=True,
        need_redis=True,
        need_rabbitmq=False,
        need_elasticsearch=False,
        need_kafka=False,
        need_kibana=False
    )
    output |= aelf_infra_output
    aelf_node_output = aelf_node_module.run(
        plan,
        with_aefinder_feeder=False
    )
    output |= aelf_node_output

    zk_vote_relayer_output = zk_vote_relayer_module.run(
        plan,
        advertised_ip=advertised_ip,
        mongodb_url=aelf_infra_output["mongodb_url"],
        redis_url=aelf_infra_output["redis_url"],
        aelf_node_url=aelf_node_output["aelf_node_url"]
    )
    output |= zk_vote_relayer_output

    return output