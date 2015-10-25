# Install Salt From Source

python-dev:
  pkg.installed

python-m2crypto:
  pkg.installed

{% set home = "/var/repo" -%}
{% set branch = "2015.8.1" -%}

# You can set this to a GitHub Pull Request ID
{% set pull_request = False -%}

{{ home }}/salt-requirements.txt:
  file.managed:
    - source: salt://files/salt_requirements.txt

salt_home:
  file.directory:
    - name: {{ home }}

# Ensure the pkg is not installed
salt-no-packages:
  pkg.absent:
    - salt-common

salt_requirements:
  cmd:
    - run
    - name: pip install -r {{ home }}/salt_requirements.txt"
    - shell: /bin/bash
    - require:
      - pkg: salt-no-packages

salt_github:
  git.latest:
    - name: https://github.com/saltstack/salt.git
    - rev: {{ branch }}
    - target: {{ home }}/salt-repo
    - unless: salt-call --version
    - user: vagrant
    - require:
      - cmd: salt_requirements

{% if pull_request %}
fetch_pull_request:
  cmd:
    - run
    - cwd: {{ home }}/salt-repo
    - unless: {{ virtualenv }}/bin/salt-call --version
    - name: "git fetch origin refs/pull/{{ pull_request }}/head:refs/remotes/origin/pr/{{ pull_request }}"
    - user: vagrant
    - require:
      - git: salt_github

checkout_pull_request:
  cmd:
    - run
    - cwd: {{ home }}/salt-repo
    - unless: {{ virtualenv }}/bin/salt-call --version
    - name: "git checkout origin/pr/{{ pull_request }}"
    - user: vagrant
    - require:
      - cmd: fetch_pull_request
{% endif %}

install_salt_dev:
  cmd:
    - run
    - cwd: {{ home }}
    - unless: salt-call --version
    - name: pip install -e {{ home }}/salt-repo
    - require:
      - git: salt_github