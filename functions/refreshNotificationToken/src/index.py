from appwrite.client import Client

# You can remove imports of services you don't use
from appwrite.services.account import Account
from appwrite.services.avatars import Avatars
from appwrite.services.databases import Databases
from appwrite.services.functions import Functions
from appwrite.services.health import Health
from appwrite.services.locale import Locale
from appwrite.services.storage import Storage
from appwrite.services.teams import Teams
from appwrite.services.users import Users
from google.oauth2 import service_account
from google.auth.transport import requests


"""
  'req' variable has:
    'headers' - object with request headers
    'payload' - request body data as a string
    'variables' - object with function variables

  'res' variable has:
    'send(text, status)' - function to return text response. Status code defaults to 200
    'json(obj, status)' - function to return JSON response. Status code defaults to 200

  If an error is thrown, a response with code 500 will be returned.
"""


def main(req, res):
    try:
        client = Client().set_endpoint(endpoint='https://www.hottyserver.com/v1').set_project(value='636bd00b90e7666f0f6f').set_key(
            value='fea5a4834f59d20452556c1425ff812265a90d6a0f06ca7f6785663bdc37ce41e1e17b3bb81c73e0d2e236654136e7b4b00e41c735f07cb69c0bc8a1ffe97db7000b9f891ec582eb7359842ed1d12723b98ab6b46588076079bbf95438d767baab61dd4b8da8070ea6f0e0f914f86667361285c50a5fe4ac22be749b3dfea824')

        # You can remove services you don't use
        account = Account(client)
        avatars = Avatars(client)
        database = Databases(client)
        functions = Functions(client)
        health = Health(client)
        locale = Locale(client)
        storage = Storage(client)
        teams = Teams(client)
        users = Users(client)
        token = _get_access_token()
        data = str(token)
        print(type(data))
       # database.get_document(database_id="636d59d7a2f595323a79",
        #                      collection_id="63eba9bfd3923130eb3d",document_id="63ebaa165a793004bb38")

        database.update_document(database_id="636d59d7a2f595323a79",
                               collection_id="63eba9bfd3923130eb3d", data={"fcmNotifications": data},document_id="63ebaa165a793004bb38")

        return res.json({
            "areDevelopersAwesome": True,
        })
    except Exception as e:
        print(e)

        return res.json({
            "areDevelopersAwesome": e,
        })


def _get_access_token():

    credentials = service_account.Credentials.from_service_account_info(
        {"type": "service_account",
         "project_id": "hotty-189c7",
            "private_key_id": "676bc2e0159a50432a995af5b22cbd390bc3570e",
            "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEuwIBADANBgkqhkiG9w0BAQEFAASCBKUwggShAgEAAoIBAQDYqv4oaBxZfSts\nCjfydmjBP1vA8flEIILicSnuaOgOY+sDkkkUlLPaKX8sC/BjPPwqEhzeBX8UE6Du\n1SDzlcJhefqeRptGr0HJ1DsiI0YdY8YsoMETSrTgNmbLOnVB4J5vY8SORO5sA+4t\nadjZbcXOU0HrW73cSj5b01KgekJp7bjrUKQtg5Dur1mGhwnCu0NCR4MQ/KMN5Bv8\nc5FbJECqsKTkIdHfBZPDZXrKGk6L0XYwTyXBCA6l714VsQpPTYnpZj1Jepp2Brd4\nr5/3chvDEJ5BGtvj7OWqoo4ZSj8YEbgTJ+5+jJMc8PECKkldQVxkuuxAocW3im4+\nolUlA5bPAgMBAAECgf8dhibuJF59Pg9+DkH1bx+aH5/QKuhx0Ni1QvGxrBP2YuDO\nmu5rXdSZIfoZuUm5lfdOMMxpcTfHN3CH8ItXiRTsFqLu5eZmXvjE7LrocQtauorw\n+cI8EnOxwZl56jAz1ORoHvCdBB/AN6HlqW/Uv2OKgtSiPnrm/dmvQHPddh6FtixL\nQ88W8X8FeQhdm1kv2kjWu9MfeZb8NU9GTg3qrf50wd33uCfK0HVC3JNFDTZu8pCh\nlq7gAm2JHXtVzPFSuMHYVBG7Ya2WGuUOj4/WK0zItBUVHHEvFjb1AbhqXCGW8J+q\nbn0ELVUj8ahmX/TKR4SQjP6k+Mb9eA+HJQ3mzuECgYEA+USicVi6ZxzVEUvTSKs6\n0yTyRbVKB0R/kMdZVCfurEZ0dRvnf8gRrtIdoZqAA9LsUpqvpzbIrUw1smAU0Vty\ngcbSUCG93riFPurzCCn1aSpSNpjaEcOcanzA4jaJS3g024PVphA5EkZLQTzd0ejM\nCWSt+u3TKALn9tz06EkPQiECgYEA3oT4bscZq9cihJwRojzhwARdXvjhywbSq4fU\nS5Aj43ztPv7aCj8sLtf+3GCVal+oIkcZxgeuFEfEhtixY9uQeSBF30AImhoHFtiK\n1IDysUnEtRfBWaniDY5tuN/CT2MgFuG6213BLzGKa6lbckiFPYvCBxj54q5hW9Lq\nGzxdmu8CgYBD1MOHqKeA672naUTjn4TwdDthcMXmWGOGWFkcp4kxZDLIs4E5qo31\nTsQ1d7+iSsF4cROfoy7UycpK8g54MjRk0F/m4meyte+8gV8FN7XKmnOo28trzhlA\neRZb+I8/9EQeADAhcoS1Tl+oLxIFzx3G6JjXkeRGHRRWfyY+F7OJQQKBgQCTjBgv\nXFXpW/3HcLVAnp4SdNJ05xLRTPTkSGy8rhceAPhPjS2HHdxuM0sLVf+9STBzijHM\n3crQJ8Zoo8b8L9rcdkneftc1V4zb2To1Lku+wutsKRRMIBmEY6zdqYFuoovkoEkG\nrGQspuzh9qpsXSn8ZW+CxUzswjRMbs5MwPpQgQKBgBxpk2m/NQia9EKp1DA0nPaO\nYli3YRyNpwixaQYawMkgiJ9XogBo7AEeDDkMwiJQKDnrljVNJO/IoU7kS7thrbVC\nlfbYPv9piTmWh6hOH/IOS2NSszxmNcjKiuPZFDTDo7+ydqkvy9EjUdStEMSDTaNJ\nOQiDldhooT7OeUkSuACj\n-----END PRIVATE KEY-----\n",
            "client_email": "notificationsserviceaccount@hotty-189c7.iam.gserviceaccount.com",
            "client_id": "110333830221699268096",
            "auth_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token",
            "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
            "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/notificationsserviceaccount%40hotty-189c7.iam.gserviceaccount.com"}, scopes=["https://www.googleapis.com/auth/firebase.messaging"])
    request = requests.Request()
    credentials.refresh(request)
    return credentials.token
