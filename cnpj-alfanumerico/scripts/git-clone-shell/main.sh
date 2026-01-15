#!/bin/bash

./clone_repos.sh ../../gits/discovery/sinistro
./change_branch.sh ../../gits/discovery/sinistro fix-cnpj-alfanumerico-plan
./copy_folder_to_repos.sh ../../fluxo-trabalho/.cnpj_alfanumerico ../../gits/discovery/sinistro