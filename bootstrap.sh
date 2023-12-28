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

    echo "init project in go"

    # make project dir if not exists and cd into it
    if [ -d "go-operator" ]; then
        gum confirm "delete go-operator?" && rm -rf "go-operator"
    fi
    mkdir -p "go-operator" && pushd "go-operator" || exit

    go mod init laidback.github.io/soft-serve/v2
    operator-sdk init --plugins "go/v4" \
        --domain laidback.github.io \
        --project-name soft-serve \
        --owner "Lukas.Ciszewski" \
        --repo github.com/laidback/soft-serve/v2 \
    go get sigs.k8s.io/controller-runtime@v0.15.0
    go mod tidy && go mod vendor

    # go back to where we came from
    popd
}

# init operator-sdk project with helm chart
# in a separate directory. This is a workaround
# for the issue with the operator-sdk helm plugin
# and go plugin in the same project.
init_helm_operator() {

    echo "init helm operator"
    # make project dir if not exists and cd into it
    if [ -d "helm-operator" ]; then
        gum confirm "delete helm-operator?" && rm -rf "helm-operator"
    fi
    mkdir -p "helm-operator" && pushd "helm-operator" || exit

    operator-sdk init --plugins helm \
        --domain laidback.github.io \
        --group=apps \
        --kind=SoftOps \
        --version=v1alpha1


    # go back to where we came from
    popd
}

# setup project directory and change into it.
setup_project_dir(){
    local err=0

    project=$(gum input \
        --prompt "Project name" \
        --value "softer-serve"); err=$?
    [ $err -ne 0 ] && exit $err

    # make project dir if not exists and cd into it
    # if exists, cd into it
    mkdir -p "$project" && cd "$project" || exit
}

# main function
main() {
    # array of commands to run
    local cmds=(
        setup_project_dir
        init_go_operator
        init_helm_operator
    )

    # user input for *selected* commands to run
    local selected=$(echo "${cmds[@]}" | \
        xargs gum choose \
        --no-limit \
        --ordered \
        --select-if-one); err=$?
    [ $err -ne 0 ] && exit $err

    # run selected commands
    for cmd in $selected; do
        echo "running $cmd ..."
        $cmd
    done
}

# run main function portable for bash and zsh shells
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

