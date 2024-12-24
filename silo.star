SERVICE_NAME = "zk-vote-relayer-silo"

IMAGE_NAME = "gldeng/zkvoterelayer.silo:sha-39343c5"

APPSETTINGS_TEMPLATE_FILE = "/static_files/silo/appsettings.json.template"


def run(
    plan, 
    advertised_ip,
    mongodb_url,
    redis_url,
    aelf_node_url,
    gateway_port=20031,
    silo_port=10031
):
    keys_artifact_name = plan.upload_files(
        src = "/static_files/silo/W1ptWN5n5mfdVvh3khTRm9KMJCAUdge9txNyVtyvZaYRYcqc1.json"
    )
    artifact_name = plan.render_templates(
        config = {
            "appsettings.json": struct(
                template=read_file(APPSETTINGS_TEMPLATE_FILE),
                data={
                    "AdvertisedIP": advertised_ip,
                    "GatewayPort": gateway_port,
                    "SiloPort": silo_port,
                    "RedisHostPort": redis_url.split("/")[-1],
                    "MongoDbUrl": mongodb_url,
                    "AelfNodeUrl": aelf_node_url,
                },
            ),
        },
    )

    config = ServiceConfig(
        image = IMAGE_NAME,
        files={
            "/app/config": artifact_name,
            "/app/keys": keys_artifact_name,
        },
        ports={
            "gateway": PortSpec(number=gateway_port),
            "silo": PortSpec(number=silo_port),
        },
        public_ports={
            "gateway": PortSpec(number=gateway_port),
            "silo": PortSpec(number=silo_port),
        },
        entrypoint = [
            "/bin/sh", 
            "-c", 
            "cp /app/config/appsettings.json /app/appsettings.json && cat /app/appsettings.json && dotnet ZkVoteRelayer.Silo.dll"
        ],
    )
    plan.add_service(SERVICE_NAME, config)
