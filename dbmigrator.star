
IMAGE_NAME = "gldeng/zkvoterelayer.dbmigrator:sha-0511a8a"
APPSETTINGS_TEMPLATE_FILE = "/static_files/dbmigrator/appsettings.json.template"

def run(plan, mongodb_url, redis_url):

    artifact_name = plan.render_templates(
        config = {
            "appsettings.json": struct(
                template=read_file(APPSETTINGS_TEMPLATE_FILE),
                data={
                    "MongoDbUrl": mongodb_url,
                    "RedisHostPort": redis_url.split("/")[-1]
                },
            ),
        },
    )
    result = plan.run_sh(
        run = "cp /app/config/appsettings.json /app/appsettings.json && dotnet /app/ZkVoteRelayer.DbMigrator.dll",
        name = "zk-vote-relayer-dbmigrator",
        image = IMAGE_NAME,
        files={
            "/app/config": artifact_name,
        },
        description = "Initialize mongodb"  
    )

    plan.print(result.code)  # returns the future reference to the code
    plan.print(result.output) # returns the future reference to the output
