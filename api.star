
SERVICE_NAME = "zk-vote-relayer-api"
IMAGE_NAME = "gldeng/zkvoterelayer.httpapi.host:sha-0511a8a"
STATIC_FILES_DIR = "/static_files/api"
APPSETTINGS_TEMPLATE_FILE = "{STATIC_FILES_DIR}/appsettings.json.template".format(STATIC_FILES_DIR=STATIC_FILES_DIR)

def run(
    plan,
    redis_url,
    mongodb_url,
    api_port=8093
):

    artifact_name = plan.render_templates(
        config = {
            "appsettings.json": struct(
                template=read_file(APPSETTINGS_TEMPLATE_FILE),
                data={
                    "RedisHostPort": redis_url.split("/")[-1],
                    "MongoDbUrl": mongodb_url,
                    "Host": SERVICE_NAME,
                    "Port": api_port,
                },
            )
        },
    )
    plan.add_service(SERVICE_NAME, ServiceConfig(
        image=IMAGE_NAME,
        ports={
            "http": PortSpec(number=api_port),
        },
        files={
            "/app/config": artifact_name,
        },
        entrypoint = [
            "/bin/sh", 
            "-c", 
            "cp /app/config/* /app/ && cat /app/appsettings.json && dotnet ZkVoteRelayer.HttpApi.Host.dll"
        ],
    ))
    return "http://{host}:{port}".format(host=SERVICE_NAME, port=api_port)