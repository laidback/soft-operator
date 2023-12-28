#!/usr/bin/env bash
#
# Run the full lifecycle of the operator-sdk project
# from init to deploy.
#
# variables
# domain="laidback.github.io"
# project="soft-serve"
# repo="github.com/laidback/soft-serve"
# owner="laidback"
# version="v1alpha1"
# err=0
#
# init operator-sdk project in go
init_go_operator() {
    go mod init laidback.github.io/soft-serve/v2
    operator-sdk init \
        --domain laidback.github.io \
        --project-name soft-serve \
        --owner "Lukas.Ciszewski" \
        --repo github.com/laidback/soft-serve/v2 \
        --plugins "go/v4"
    go mod tidy && go mod vendor
}

