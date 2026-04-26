age_key_file := '~/.age-key.txt'
encrypted_age_key := 'secret/age.agekey.encrypted'
age_key := 'secret/age.agekey'

default:
    @just --list

age-encrypt-age own=age_key_file:
    age -i {{ own }} -e -o {{ encrypted_age_key }} {{ age_key }}

age-decrypt-age own=age_key_file:
    age -i {{ own }} -d -o {{ age_key }} {{ encrypted_age_key }}

[unix]
lint:
    ./scripts/lint.sh

[unix]
kube-init:
    kubectl kustomize kubernetes/cluster/kevinnitrohomelab | envsubst | sops -d /dev/stdin | kubectl apply -f -

[arg("namespace", long="namespace", short="n", help="Namespace to create")]
[private]
kube-create-ns namespace="egolia":
    kubectl create namespace {{ namespace }} --dry-run=client -o yaml | kubectl apply -f -

[arg("secret-name", long="secret-name", short="s", help="Name of the Kubernetes secret")]
[arg("namespace", long="namespace", short="n", help="Namespace to create the secret in")]
[private]
kube-add-age-secret secret-name="egolia-sops-age" namespace="egolia": kube-create-ns
    kubectl create secret generic  {{ secret-name }} --from-file=age.agekey={{ age_key }} -n {{ namespace }} --dry-run=client -o yaml | kubectl apply -f -
