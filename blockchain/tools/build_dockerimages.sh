#!/bin/bash

PRIVNET_TAG="privnet-v0.4"

while getopts ":p:" opt; do
  case $opt in
    p) DOCKER_PUSH="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

CURRENT_DIR=$(pwd)

function build_binary_and_docker {
    BRANCH="${1}"
    REPO="${GOPATH}/src/github.com/elastos/${2}"
    WORKDIR="${3}"
    BINARY="${4}"
    DOCKERIMAGE="${5}"
    GITHUB_PULL="${6}"
    DOCKER_PUSH_TAGS="${7}"

    cd $REPO
    if [ "${GITHUB_PULL}" == "yes" ]
    then
        git checkout master
        git pull
        git checkout $BRANCH
        git pull
    fi
    mkdir -p $TMPDIR/$WORKDIR/$BINARY
    cp -r $CURRENT_DIR/$WORKDIR/* $TMPDIR/$WORKDIR/
    cp -r * $TMPDIR/$WORKDIR/$BINARY/
    docker build -t "$DOCKERIMAGE:latest" -f $TMPDIR/$WORKDIR/Dockerfile $TMPDIR/$WORKDIR/
    if [ "${DOCKER_PUSH}" == "yes" ]
    then
        if [ ! -z "${DOCKER_PUSH_TAGS}" ]
        then
            docker tag "$DOCKERIMAGE:latest" "$DOCKERIMAGE:$BRANCH"
            docker push "$DOCKERIMAGE:$BRANCH"
            docker tag "$DOCKERIMAGE:latest" "$DOCKERIMAGE:$PRIVNET_TAG"
            docker push "$DOCKERIMAGE:$PRIVNET_TAG"
        fi
        docker push "$DOCKERIMAGE:latest"
    fi
    cd $CURRENT_DIR
}

function build_docker {
    WORKDIR="${1}"
    BINARY="${2}"
    DOCKERIMAGE="${3}"
    DOCKER_PUSH_BRANCH_TAG="${4}"
    DOCKER_PUSH_TAGS="${5}"

    mkdir -p $TMPDIR/$WORKDIR/$BINARY
    cp -r $CURRENT_DIR/$WORKDIR/* $TMPDIR/$WORKDIR/
    docker build -t "$DOCKERIMAGE:latest" -f $TMPDIR/$WORKDIR/Dockerfile $TMPDIR/$WORKDIR/
    if [ "${DOCKER_PUSH}" == "yes" ]
    then
        if [ ! -z "${DOCKER_PUSH_TAGS}" ]
        then
            docker tag "$DOCKERIMAGE:latest" "$DOCKERIMAGE:$DOCKER_PUSH_BRANCH_TAG"
            docker push "$DOCKERIMAGE:$DOCKER_PUSH_BRANCH_TAG"
            docker tag "$DOCKERIMAGE:latest" "$DOCKERIMAGE:$PRIVNET_TAG"
            docker push "$DOCKERIMAGE:$PRIVNET_TAG"
        fi
        docker push "$DOCKERIMAGE:latest"
    fi
    cd $CURRENT_DIR
}

build_binary_and_docker "v0.3.5" "Elastos.ELA" "ela-mainchain" "ela" \
    "cyberrepublic/elastos-mainchain-node" "yes" "yes"

build_binary_and_docker "v0.1.1" "Elastos.ELA.Arbiter" "ela-arbitrator" "arbiter" \
    "cyberrepublic/elastos-arbitrator-node" "yes" "yes"

build_binary_and_docker "v0.1.2" "Elastos.ELA.SideChain.ID" "ela-sidechain/did" "did" \
    "cyberrepublic/elastos-sidechain-did-node" "yes" "yes"

build_binary_and_docker "v0.1.2" "Elastos.ELA.SideChain.Token" "ela-sidechain/token" "token" \
    "cyberrepublic/elastos-sidechain-token-node" "yes" "yes"

build_binary_and_docker "dev" "Elastos.ELA.SideChain.ETH" "ela-sidechain/eth" "eth" \
    "cyberrepublic/elastos-sidechain-eth-node" "no" "no"

build_docker "ela-sidechain/eth/oracle" "oracle" \
    "cyberrepublic/elastos-sidechain-eth-oracle" "dev" "yes"

build_binary_and_docker "master" "Elastos.ORG.Wallet.Service" "restful-services/wallet-service" "service" \
    "cyberrepublic/elastos-wallet-service" "yes" "no"

build_binary_and_docker "master" "Elastos.ORG.SideChain.Service" "restful-services/sidechain-service" "service" \
    "cyberrepublic/elastos-sidechain-service" "yes" "no"

build_binary_and_docker "master" "Elastos.ORG.API.Misc" "restful-services/api-misc" "misc" \
    "cyberrepublic/elastos-api-misc-service" "yes" "no"

cd $CURRENT_DIR
