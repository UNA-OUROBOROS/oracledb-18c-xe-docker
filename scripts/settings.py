import platform


def get_config():
    os_type = platform.system()
    unix_like = os_type != "Windows"
    config = {
        "container_name": "devXE",
        "platform": {
            "type": os_type,
            "unix_like": unix_like
        },
        "prerequisites": {
            "save_location": "software/",
            "pkgs": [
                {
                    "pkg_name": "oracle-database-xe-18c.rpm",
                    "pkg_url": "https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-18c-1.0-1.x86_64.rpm"
                },
                {
                    "pkg_name": "oracle-database-preinstall-18c.rpm",
                    "pkg_url": "https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm"
                }
            ]
        }



    }
    return config
