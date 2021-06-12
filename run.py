from github_webhook import Webhook
from flask import Flask
from flask import render_template
import subprocess
import shlex
import logging
import os.path
from subprocess import call
from jinja2 import Template, Environment, FileSystemLoader
from flask import request, Response
from config import conf
app = Flask(__name__)  # Standard Flask app
webhook = Webhook(app) # Defines '/postreceive' endpoint
log = logging.getLogger("main")


@app.route("/")        # Standard Flask endpoint
def hello_world():
    return "Hello, World!"

@app.route("/test")
def test():
    return render_template("abc.html")

@app.route("/main")
def main():
    APP_ROOT = os.path.dirname(os.path.abspath(__file__))
    APP_TXT = os.path.join(APP_ROOT, "templates")
    f = request.args.get("f")
    if f and len(f) > 0:
        if str(f).endswith("html"):
            return render_template(f)
        else:
            with open(os.path.join(APP_TXT, f))as f:
                s = f.read()
            return Response(s, mimetype="text/plain")
    return render_template("index.html")

@webhook.hook(event_type="Push Hook")        # Defines a handler for the 'push' event
def on_push(data):
    # print("Got push with: {0}".format(data))
    # print(data.get("event_name"))
    project = data.get("repository").get("name")
    if not project in conf:
        return 404

    git_ssh_url = data.get("repository").get("git_ssh_url")
    git_source_dir = conf.get(project).get("dir")

    status = git_clone_or_pull(git_ssh_url, git_source_dir)
    if status:
        print("successul!")
    else:
        print("failed!")

    compare_list = conf.get(project).get("vs")
    if len(compare_list) < 1:
        return


    detail = []
    only_git_files = []
    only_remote_files = []

    for vs in compare_list:
        source_dir = vs.get("source")
        destination_dir = vs.get("destination")
        cmd_out = subprocess.Popen(shlex.split("/bin/sh " + "find_diff.sh " + "-s " + source_dir + " -d " + destination_dir + " -t " + "templates"), stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print(cmd_out.stderr.read())
        result = cmd_out.stdout.read().decode("utf-8")
        result_list = result.split("\n")
        base_dir = result_list[0]
        contain_both_compare_html_list = result_list[1]
        only_git_find_file_name_list = result_list[2]
        only_remote_file_name_list = result_list[3]

        with open(contain_both_compare_html_list) as f:
            line_lists = f.readlines()
        for l in line_lists:
            d = l.split()[0]
            f = l.split()[1]
            n = l.split()[2]
            detail.append({"file": d, "num": n, "url": "/main?f=" + f})

        with open(only_git_find_file_name_list) as f:
            line_lists = f.readlines()
        for l in line_lists:
            d = l.split()[0]
            f = l.split()[1]
            only_git_files.append({"file": d, "url": "/main?f=" + f})

        with open(only_remote_file_name_list) as f:
            line_lists = f.readlines()
        for l in line_lists:
            d = l.split()[0]
            f = l.split()[1]
            only_remote_files.append({"file": d, "url": "/main?f=" + f})

    print(detail)
    print(only_git_files)
    print(only_remote_files)

    load = FileSystemLoader('templates')
    env = Environment(loader=load)
    template = env.get_template("table.html")
    result = template.render(detail=detail, only_git_files=only_git_files, only_remote_files=only_remote_files)
    with open("templates/index.html", "w") as f:
        f.write(result)



def git_clone_or_pull(git_ssh_url, project_dir):
    status = 1
    if os.path.isdir(project_dir):
        status = call(["git", "-C", project_dir, "pull"])
    else:
        os.mkdir(project_dir)
        status = call(["git", "clone", git_ssh_url, project_dir])
    if status == 0:
        return True
    return False



if __name__ == "__main__":
    app.run(host="0.0.0.0", port=3456,debug=True)
