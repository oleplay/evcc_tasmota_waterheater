from os import environ

def get_env():
    env_vars = {}
    if environ.get("WATERHEATER_URL"):
        env_vars['waterheater_url'] = environ.get("WATERHEATER_URL")
        # trim trailing slash
        if env_vars['waterheater_url'][-1] == '/':
            env_vars['waterheater_url'] = env_vars['waterheater_url'][:-1]
    else:
        print("WATERHEATER_URL not set")
        print("Using default: http://waterheater")
        env_vars['waterheater_url'] = "http://waterheater"
    return env_vars
