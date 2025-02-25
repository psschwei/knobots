#!/bin/bash

# Copyright 2021 The Knative Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

log=""
create_pr="false"

cd main

if [[ ! -f go.mod ]]; then
    echo "No go mod, skipping..."
else
    export FILES=( $(find -path './vendor' -prune -o -path './third_party' -prune -o -name '*.pb.go' -prune -o -type f -name '*.go' -print) )
    export GENFILES=( $(git ls-files | xargs git check-attr linguist-generated | grep 'true$' | cut -d: -f1) )
    for i in "${GENFILES[@]}"; do
        FILES=(${FILES[@]//*$i*})
    done
    if (( ${#FILES[@]} > 0 )); then
        log=$(goimports -w "${FILES[@]}")
        log="$log $(gofmt -s -w "${FILES[@]}")"
        create_pr="true"
    else
        echo No Go files found.
    fi
fi

# Ensure files have the same owner as the checkout directory.
# See https://github.com/knative-sandbox/knobots/issues/79
chown -R --reference=. .

echo "create_pr=${create_pr}" >> $GITHUB_ENV

echo "log=$log" >> $GITHUB_OUTPUT
