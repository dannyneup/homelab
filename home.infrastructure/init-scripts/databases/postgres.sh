#!/bin/bash
set -euo pipefail

validate_environment() {
    local vars=("DATABASES" "USERS" "PASSWORDS" "POSTGRES_ADMIN_USER")
    for var in "${vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            printf "Error: Environment variable %s is not set or empty.\n" "$var" >&2
            return 1
        fi
    done
}

parse_environment_variable() {
    local input="$1"
    local -n output_array="$2"
    IFS=',' read -ra output_array <<< "$input"
}

validate_array_lengths() {
    if [[ "${#DBS[@]}" -ne "${#USERS[@]}" || "${#DBS[@]}" -ne "${#PASSWORDS[@]}" ]]; then
        printf "Error: DATABASES, USERS, and PASSWORDS must have the same number of entries.\n" >&2
        return 1
    fi
}

create_db_user() {
    local db="$1"
    local user="$2"
    local password="$3"

    printf "Creating database '%s' and user '%s'...\n" "$db" "$user"

    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_ADMIN_USER" <<-EOSQL
        CREATE DATABASE $db;
        CREATE USER $user WITH ENCRYPTED PASSWORD '$password';
        GRANT ALL PRIVILEGES ON DATABASE $db TO $user;
EOSQL
}

main() {
    validate_environment || return 1

    local DBS USERS PASSWORDS
    parse_environment_variable "$DATABASES" DBS
    parse_environment_variable "$USERS" USERS
    parse_environment_variable "$PASSWORDS" PASSWORDS

    validate_array_lengths || return 1

    for i in "${!DBS[@]}"; do
        create_db_user "${DBS[i]}" "${USERS[i]}" "${PASSWORDS[i]}"
    done
}

main
