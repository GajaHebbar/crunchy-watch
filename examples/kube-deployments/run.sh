#!/bin/bash

# Copyright 2016-2018 Crunchy Data Solutions, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$DIR/cleanup.sh

[ -z "$WATCH_NAMESPACE" ] && echo "Need to set WATCH_NAMESPACE" && exit 1
[ -z "$WATCH_IMAGE_TAG" ] && echo "Need to set WATCH_IMAGE_TAG" && exit 1
[ -z "$WATCH_IMAGE_PREFIX" ] && echo "Need to set WATCH_IMAGE_PREFIX" && exit 1

# Create 'watch-hooks-configmap'.
$WATCH_CLI -n $WATCH_NAMESPACE create configmap watch-hooks-configmap \
	--from-file=./hooks/watch-pre-hook \
	--from-file=./hooks/watch-post-hook

expenv -f ../rbac.yaml | $WATCH_CLI -n $WATCH_NAMESPACE create -f -

if [[ ${WATCH_CLI} -eq "oc" ]]
then
        oc adm policy add-scc-to-user privileged -z pg-watcher -n $WATCH_NAMESPACE
fi

expenv -f $DIR/watch.json  | $WATCH_CLI -n $WATCH_NAMESPACE create -f -

