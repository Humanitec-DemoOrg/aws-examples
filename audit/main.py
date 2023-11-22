import requests
import re
from urllib.parse import parse_qs, urlparse
from urllib.parse import quote


def file_put_contents(file_path, content):
    with open(file_path, "w") as file:
        file.write(content)


date_from = "2023-11-21T00:00:00Z"
date_to = "2023-11-21T23:59:59Z"
per_page = 100
page = ""
org = "myorg"
token = "mytoken"
c = -1
while True:
    c = c + 1
    url = "https://api.humanitec.io/orgs/{org}/audit-logs?from={date_from}&to={date_to}&per_page={per_page}&{page}".format(
        org=org,
        date_from=date_from,
        date_to=date_to,
        per_page=per_page,
        page=(page if page != "" else ""),
    )

    print(url)

    headers = {"Authorization": "Bearer {}".format(token)}

    r = requests.get(url, headers=headers)

    file_path = "/tmp/{}.json".format(c)
    file_content = r.text

    file_put_contents(file_path, file_content)

    # below extracts the next &page
    if "Link" in r.headers:
        link = r.headers["Link"]
        print(link)

        pattern = r"<(.*?)>"

        matches = re.findall(pattern, link)

        if matches:
            extracted_query_string = matches[0]
            parsed_query_string = parse_qs(urlparse(extracted_query_string).query)

            if "page" in parsed_query_string:
                page = "page={}".format(quote(parsed_query_string["page"][0]))
            else:
                page = ""
                break

        else:
            page = ""
            break

    else:
        break
