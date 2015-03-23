# -*- coding: utf-8 -*-

import os
import jinja2

dest = "web"

# Set up templating infrastructure

template_dir = os.path.join(os.path.dirname(__file__), "templates")
jinja_env = jinja2.Environment(loader = jinja2.FileSystemLoader(template_dir))

def render_str(template, **params):
    t = jinja_env.get_template(template)
    return t.render(params)

def write(path, string):
	f = file(path, "w")
	f.write(string)
	f.close()

# End set up templating infrastructure

# Build templates and write them to destination

introduction = render_str("base/introduction.html")
write(os.path.join(dest, "introduction.html"), introduction.encode('utf8'))
index = render_str("base/make-game.html");
write(os.path.join(dest, "index.html"), index.encode('utf8'))