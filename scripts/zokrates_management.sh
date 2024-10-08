#!/bin/bash
##########################
# Scripted by jjavieralv #
##########################
#set -x
DOCKER_IMAGE='zokrates/zokrates:latest'
DOCKER_BASECOMMAND='docker run --rm -it'

FOLDER_TO_MOUNT='.'

### actions
COMPILE=0
# compile
SETUP=0
# execute the program
COMPUTE_WITNESS=0
# generate a proof of computation
GENERATE_PROOF=0
# export a solidity verifier
EXPORT_VERIFIER=0
# or verify natively
VERIFY=0

INSPECT=0

VERBOSE=""

## SUPPORT FUNCTIONS 
function check_errors(){
    if [[ $? -ne 0 ]];then
        echo "ERROR: $1"
        exit
    fi
}

## PREVIOUS CHECKS

function check_dependencies(){
    docker --version >> /dev/null
    check_errors "ERROR: Docker not installed"


}

## ZOKRATES actions

function compile() {
    echo "Compiling using ZoKrates with the provided code file path: ${FOLDER_TO_MOUNT}/${CODEFILE_PATH}"
    DOCKER_COMMAND="${DOCKER_BASECOMMAND} -v $(pwd)/${FOLDER_TO_MOUNT}:/tmp/zokrates_test -w /tmp/zokrates_test ${DOCKER_IMAGE} zokrates compile -i ${CODEFILE_PATH} ${VERBOSE}"
    eval $DOCKER_COMMAND
    check_errors "Compilation failed"
}

function setup() {
    echo "Setting up using ZoKrates with the provided proving scheme: ${PROVING_SCHEME}"
    DOCKER_COMMAND="${DOCKER_BASECOMMAND} -v $(pwd)/${FOLDER_TO_MOUNT}:/tmp/zokrates_test -w /tmp/zokrates_test ${DOCKER_IMAGE} zokrates setup -s ${VERBOSE}"
    eval $DOCKER_COMMAND
    check_errors "Setup failed"
}

function compute_witness() {
    echo "Computing witness using ZoKrates with the provided arguments: ${WITNESS_ARGUMENTS}"
    DOCKER_COMMAND="${DOCKER_BASECOMMAND} -v $(pwd)/${FOLDER_TO_MOUNT}:/tmp/zokrates_test -w /tmp/zokrates_test ${DOCKER_IMAGE} zokrates compute-witness -a ${WITNESS_ARGUMENTS} ${VERBOSE}"
    eval $DOCKER_COMMAND
    check_errors "Computing witness failed"
}

function generate_proof() {
    echo "Generating proof using ZoKrates"
    DOCKER_COMMAND="${DOCKER_BASECOMMAND} -v $(pwd)/${FOLDER_TO_MOUNT}:/tmp/zokrates_test -w /tmp/zokrates_test ${DOCKER_IMAGE} zokrates generate-proof ${VERBOSE}"
    eval $DOCKER_COMMAND
    check_errors "Proof generation failed"
}

function export_verifier() {
    echo "Exporting verifier using ZoKrates"
    DOCKER_COMMAND="${DOCKER_BASECOMMAND} -v $(pwd)/${FOLDER_TO_MOUNT}:/tmp/zokrates_test -w /tmp/zokrates_test ${DOCKER_IMAGE} zokrates export-verifier ${VERBOSE}"
    eval $DOCKER_COMMAND
    check_errors "Verifier export failed"
}

function verify() {
    echo "Verifying proof using ZoKrates"
    DOCKER_COMMAND="${DOCKER_BASECOMMAND} -v $(pwd)/${FOLDER_TO_MOUNT}:/tmp/zokrates_test -w /tmp/zokrates_test ${DOCKER_IMAGE} zokrates verify ${VERBOSE}"
    eval $DOCKER_COMMAND
    check_errors "Verification failed"
}

function inspect() {
    echo "Verifying proof using ZoKrates"
    DOCKER_COMMAND="${DOCKER_BASECOMMAND} -v $(pwd)/${FOLDER_TO_MOUNT}:/tmp/zokrates_test -w /tmp/zokrates_test ${DOCKER_IMAGE} zokrates inspect -i ${INSPECT_FILE} ${VERBOSE}"
    eval $DOCKER_COMMAND
    check_errors "Verification failed"
}



function zokrates_actions(){
    [[ $COMPILE -eq 1 ]] && compile
    [[ $SETUP -eq 1 ]] && setup
    [[ $COMPUTE_WITNESS -eq 1 ]] && compute_witness
    [[ $GENERATE_PROOF -eq 1 ]] && generate_proof
    [[ $EXPORT_VERIFIER -eq 1 ]] && export_verifier
    [[ $VERIFY -eq 1 ]] && verify
    [[ $INSPECT -eq 1 ]] && inspect
}

function help_menu(){
echo "Usage: $0 [options]"
echo "Options:"
echo "  -c <codefile>          Compile the ZoKrates program. Specify codefile path(relative to -f)."
echo "  -e                     Export the verifier smart contract."
echo "  -h                     Display this help menu."
echo "  -a <arguments>         Specify arguments for compute the witness."
echo "  -i <file>              Inspect output file "
echo "  -I <image>             Specify the Docker image to use (default: zokrates/zokrates:latest)."
echo "  -p                     Generate the proof for the ZoKrates program."
echo "  -s                     Setup phase of the ZoKrates program."
echo "  -v                     Verify the proof."
echo "  -V                     enable verbose mode"
echo "  -w                     Compute the witness for the ZoKrates program."
echo "      -a <arguments>         Specify arguments for compute the witness."
echo ""
echo "Example:"
echo "  $0 -I zokrates/zokrates:0.7.6 -c mycode.zok -s -w 1 2 3 -p -e -v -f /my/folder/with/everything"
exit 1
}

function main(){
    check_dependencies
    zokrates_actions
}


if [[ $# -eq 0 ]]; then
    help_menu
    exit 1
fi

while getopts "I:i:Vc:swpeva:f:" opt; do
    case $opt in
        I) IMAGE="$OPTARG"
        ;;
        i) INSPECT=1
            INSPECT_FILE="$OPTARG"
        ;;
        c) COMPILE=1
            CODEFILE_PATH="$OPTARG"
        ;;
        a)  WITNESS_ARGUMENTS="$OPTARG"
            until [[ $(eval "echo \${$OPTIND}") =~ ^-.* ]] || [[ -z $(eval "echo \${$OPTIND}") ]]; do
                WITNESS_ARGUMENTS+=$(eval "echo \ \${$OPTIND}")
                OPTIND=$((OPTIND + 1))
            done
        ;;
        s) SETUP=1
        ;;
        w) COMPUTE_WITNESS=1
        ;;
        p) GENERATE_PROOF=1
        ;;
        e) EXPORT_VERIFIER=1
        ;;
        v) VERIFY=1
        ;;
        V) VERBOSE="--verbose"
        ;;
        f) FOLDER_TO_MOUNT="$OPTARG"
        ;;
        \?) echo "Invalid option -$OPTARG" >&2
            help_menu
        ;;
        :) echo "Option -$OPTARG requires an argument." >&2
            help_menu
        ;;
    esac
done

main

exit 0

