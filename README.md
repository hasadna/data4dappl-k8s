# The Data4dappl Kubernetes Environment

The Data4dappl Kubernetes environment manages most Data4dappl infrastructure as code.

## Interacting with the environment

### Prerequisites

* Using Linux / OSX? Use [Docker](https://docs.docker.com/install/)
* Using Windows? Use [Google Cloud Shell](https://cloud.google.com/shell/docs/quickstart)

#### Local infrastructure development using Minikube

* Install Minikube according to the instructions in latest [release notes](https://github.com/kubernetes/minikube/releases)
* Create the local minikube cluster
  * `minikube start`
* Verify you are connected to the cluster
  * `kubectl get nodes`
* Install Helm client
  * use the hasadna-k8s script to get the correct version -
  * `curl -L https://raw.githubusercontent.com/hasadna/hasadna-k8s/master/apps_travis_script.sh | bash /dev/stdin install_helm`
  * if you have problems, refer to helm docs - [helm client](https://docs.helm.sh/using_helm/#installing-the-helm-client)
* Initialize helm on the server
  * `helm init --history-max 2 --upgrade --wait`
* Verify helm version on both client and server
  * `helm version`
* Clone the budgetkey-k8s repo
  * `git clone https://github.com/hasadna/data4dappl-k8s.git`
* Change to the data4dappl-k8s directory
  * `cd data4dappl-k8s`
* Switch to the minikube environment
  * `source switch_environment.sh minikube`

## Common Tasks

All code assumes you are inside a bash shell with required dependencies and connected ot the relevant environment

### Deployment

Deployments are managed using [Helm](https://github.com/kubernetes/helm)

The helm server-side component is managed cluster-wide by [hasadna-k8s](https://github.com/hasadna/hasadna-k8s)

You should make sure you have the correct helm client version using hasadna-k8s script:

```
curl -L https://raw.githubusercontent.com/hasadna/hasadna-k8s/master/apps_travis_script.sh | bash /dev/stdin install_helm
```

Deploy all charts (if dry run succeeds)

```
./helm_upgrade_all.sh --install --debug --dry-run && ./helm_upgrade_all.sh --install
```

You can also upgrade a single chart

```
./helm_upgrade_external_chart.sh  socialmap
```

The helm_upgrade scripts forward all arguments to the underlying `helm upgrade` command, some useful arguments:

* For initial installation you should add `--install`
* Depending on the changes you might need to add `--recreate-pods` or `--force`
* For debugging you can also use `--debug` and `--dry-run`


### Adding an external app

* Duplicate and modify an existing chart under `charts-external` directory
* Setup the external app's continuous deployment
  * Copy the relevant steps from an existing app's [.travis.yml](https://github.com/OriHoch/socialmap-app-main-page/blob/master/.travis.yml)
  * Also, suggested to keep deployment notes in the app's [README.md](https://github.com/OriHoch/socialmap-app-main-page/blob/master/README.md#deployment)
  * Follow the app's README to setup Docker and GitHub credentials on Travis

### Creating a new environment

You can create a new environment by copying an existing environment directory and modifying the values.

See the [sk8s environments documentation](https://github.com/OriHoch/sk8s/blob/master/environments/README.md#environments) for more details about environments, namespaces and clusters.

### Modifying configuration values

The default values are at `values.yaml` - these are used in the chart template files (under `templates`, `charts`  and `charts-external` directories)

Each environment can override these values using `environments/ENVIRONMENT_NAME/values.yaml`

Finally, automation scripts write values to `values.auto-updated.yaml`

### Modifying secrets

Secrets are stored and managed directly in kubernetes and are not managed via Helm.

To update an existing secret, delete it first `kubectl delete secret SECRET_NAME`

After updating a secret you should update the affected deployments, you can use `./force_update.sh` to do that

All secrets should be optional so you can run the environment without any secretes and will use default values similar to dev environments.

Each environment may include a script to create the environment secrets under `environments/ENVIRONMENT_NAME/secrets.sh` - this file is not committed to Git.

You can use the following snippet in the secrets.sh script to check if secret exists before creating it:

```
! kubectl describe secret <SECRET_NAME> &&\
  kubectl create secret generic <SECRET_NAME> <CREATE_SECRET_PARAMS>
```
