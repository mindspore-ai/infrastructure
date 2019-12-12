import requests
import os
import signal
from mailmanclient import Client
from http.server import SimpleHTTPRequestHandler, HTTPServer


# This file used to create the default domain, list and welcome templates
# for mail list
# the configuration are listed below:
MAILMAN_CORE_ENDPOINT = os.environ.get(
    "MAILMAN_CORE_ENDPOINT",
    'http://mailman-core-0.mail-suit-service.default.svc.cluster.local:8001/3.1')

MAILMAN_CORE_USER = os.environ.get("MAILMAN_CORE_USER", "restadmin")

MAILMAN_CORE_PASSWORD = os.environ.get("MAILMAN_CORE_PASSWORD", "restpass")

DEFAULT_DOMAIN_NAME = os.environ.get("DEFAULT_DOMAIN_NAME", "openeuler.org")

DEFAULT_MAIL_LISTS = os.environ.get("DEFAULT_MAIL_LISTS", "dev,community,user")

# configure used for http server for mailman core service
TEMPLATE_FOLDER_PATH = os.environ.get("TEMPLATE_FOLDER_PATH", "templates")
TEMPLATE_SERVER_ADDRESS = os.environ.get("TEMPLATE_SERVER_ADDRESS",
                                         "127.0.0.1")
TEMPLATE_SERVER_PORT = os.environ.get("TEMPLATE_SERVER_PORT", 8000)

TEMPLATE_FOLDER_CONVERSION_EXCEPTION = {
    "domain-admin-notice-new-list": "domain:admin:notice:new-list",
    "list-user-notice-no-more-today": "list:user:notice:no-more-today",
}


class TemplateHandler(SimpleHTTPRequestHandler):

    def do_GET(self):
        # Allow access for templates folder.
        if not str.lstrip(self.path, "/").startswith("templates"):
            self.send_response(403)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(
                bytes("Only resource under templates folder are accessible!",
                      'UTF-8'))
        else:
            super(TemplateHandler, self).do_GET()


class SignalException(Exception):
    pass


def prepare_list():
    # pre-check before handling mailman core service
    if DEFAULT_DOMAIN_NAME == "":
        print("Must specify 'DEFAULT_DOMAIN_NAME' for mail list preparation.")
        exit(1)

    lists = str.split(str(DEFAULT_MAIL_LISTS).lower(), ",")
    if not os.path.exists(TEMPLATE_FOLDER_PATH):
        print("The template file folder 'TEMPLATE_FOLDER_PATH' must exits on"
              " local.")
        exit(1)

    if len(lists) == 0:
        # find out all of the lists from local folder.
        local_file = []
        for _, _, f in os.walk(os.path.join(os.getcwd(),
                                            TEMPLATE_FOLDER_PATH)):
            for file in f:
                if file.endswith(".txt"):
                    local_file.append(os.path.splitext(file)[0])
        lists = list(set(local_file))

    client = Client(MAILMAN_CORE_ENDPOINT,
                    MAILMAN_CORE_USER,
                    MAILMAN_CORE_PASSWORD)

    # Create default domain if not exists
    default_domain = client.get_domain(DEFAULT_DOMAIN_NAME)
    if default_domain is None:
        default_domain = client.create_domain(DEFAULT_DOMAIN_NAME)

    # Create default mail lists
    existing_lists = [el.list_name for el in client.lists]
    for l in lists:
        if l in existing_lists:
            print("skip creating list {0}, since it's already exist".format(l))
            continue
        else:
            print("starting to create mail list {0}".format(l))
            default_domain.create_list(l)

    # Patch template for lists
    for l in lists:
        # browse all of the dirs and find out the template files
        existing_folders = [
            f for f in os.listdir(
                os.path.join(os.getcwd(), TEMPLATE_FOLDER_PATH))]
        for d in existing_folders:
            # check the list file exists
            local_file = get_template_file(d, l)
            if os.path.exists(local_file):
                patch_content = {
                    convert_name_to_substitution(d): get_templates_url(d, l)
                }
                patch_uri = "{0}/lists/{1}.{2}/uris".format(
                    MAILMAN_CORE_ENDPOINT,
                    l,
                    DEFAULT_DOMAIN_NAME)
                response = requests.patch(
                    patch_uri, patch_content,
                    auth=(MAILMAN_CORE_USER, MAILMAN_CORE_PASSWORD))
                print("patching list {0} with template file {1}, result {2} {3}"
                      "".format(l, local_file, response.status_code, response.text))
            else:
                print("could not found template file for list {0}, path {1}, "
                      "skipping".format(l, local_file))


def convert_name_to_substitution(dir_name):
    if dir_name in TEMPLATE_FOLDER_CONVERSION_EXCEPTION:
        return TEMPLATE_FOLDER_CONVERSION_EXCEPTION[dir_name]
    return str(dir_name).replace("-", ":")


def get_templates_url(dir_name, list_name):
    return "http://{0}:{1}/templates/{2}/{3}.txt".format(
        TEMPLATE_SERVER_ADDRESS, TEMPLATE_SERVER_PORT, dir_name, list_name)


def get_template_file(folder_name, list_name):
    return os.path.join(os.getcwd(),
                        TEMPLATE_FOLDER_PATH,
                        folder_name, "{0}.txt".format(list_name))


def httpd_signal_handler(signum, frame):
    print("signal received {0}, exiting".format(signum))
    raise SignalException()


def running_templates_server():
    httpd = HTTPServer((TEMPLATE_SERVER_ADDRESS, int(TEMPLATE_SERVER_PORT)),
                       TemplateHandler)
    # Force encoding to UTF-8
    m = SimpleHTTPRequestHandler.extensions_map
    m[''] = 'text/plain'
    m.update(dict([(k, v + ';charset=utf-8') for k, v in m.items()]))
    print("template server starts at {0}:{1}".format(TEMPLATE_SERVER_ADDRESS,
                                                     TEMPLATE_SERVER_PORT))
    try:
        # exit with 0 when sigterm signal received.
        signal.signal(signal.SIGTERM, httpd_signal_handler)
        httpd.serve_forever()
    except (InterruptedError, SignalException):
        pass
    print("template server ends")
    httpd.server_close()


if __name__ == "__main__":
    prepare_list()
    running_templates_server()
