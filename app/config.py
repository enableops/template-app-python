from pydantic import BaseSettings


class AppConfig(BaseSettings):
    DB_URI: str

    class Config:
        case_sensitive = True
        env_file: str = ".env"
        env_prefix: str = "APP_"


settings = AppConfig()
