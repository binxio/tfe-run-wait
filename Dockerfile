FROM python:3.8

WORKDIR /src
ADD     . /src
RUN     python setup.py install


WORKDIR    /workspace
ENV        PYTHONUNBUFFERED=true
ENTRYPOINT ["/usr/local/bin/tfe-run-wait"]
