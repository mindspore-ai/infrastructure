# README
**NOTE**: Please read the guidance below before you starting changing any content inside of this folder.

## Introduce
This files inside of this folder are used for replacing the default mailman core email templates when the mailman suite
services starts up, therefore these files are strictly arranged by the design of mailman templates mechanism.

There are many different template substitutions provided by mailman core service, please refer [here](https://mailman.readthedocs.io/en/latest/src/mailman/rest/docs/templates.html#templated-texts)
to have a better understanding on this. In short, mailman templates are classified with different keys, here below are some of
these template keys:
1. `domain:admin:notice:new-list`: Sent to the administrators of any newly created mailing list.
2. `list:user:action:subscribe`: The message sent to subscribers when a subscription confirmation is required.
3. `list:user:notice:welcome`: The notice sent to a member when they are subscribed to the mailing list.

For instance, if we require to update the `welcome` templates of `developing` list (on domain `example.com`), we need to update the list uris via
mailman core API:
```python
import requests
requests.patch('http://{host}:{port}/3.1/lists/developing.example.com/uris',
              {'list:user:notice:welcome': 'http://{http_path_which_store_template_file}'},
               auth=({username}, {password}))
```

## Folder Structure
Mailman's `core-utils` will help us to setting up the http server and invoke mailman's core API to patch the template, in order to
achieve this automatically, the structure of folder `templates` are arranged below:

```$xslt
infrastructure
├─────────templates
│            ├───list-user-notice-welcome            //the mail template key, all ":" will be replaced by "-"
│            │                ├───────developing.txt
│            │                └───────community.txt
│            └───domain-admin-notice-new-list
│                             └───────user.txt       //the template file which is named in the format of "{list name}.txt", Do not capitalize first letter.
```
Once the content in templates folder have been updated, we can update the mailman templates through recreating the `core-utils` pods in cluster.
