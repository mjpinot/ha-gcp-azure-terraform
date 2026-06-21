# DATABASE-DR.md

# Database Disaster Recovery Runbook

## Purpose

This document describes how to recover database services when the
primary cluster becomes unavailable in a multi-cloud deployment (Azure +
GCP).

## Architecture

``` mermaid
flowchart TB

subgraph Users["Users / Client Traffic"]
    U[Applications]
end

subgraph Azure["Primary Cloud — Azure"]
    AKS[AKS Cluster]
    DB1[(Primary Database)]
    MON1[Health Checks]
end

subgraph GCP["Secondary Cloud — GCP"]
    GKE[GKE Cluster]
    DB2[(Replica Database)]
    MON2[Health Checks]
end

subgraph Control["Traffic Control"]
    DNS[DNS / Load Balancer]
end

subgraph DR["Disaster Recovery"]
    FAIL[Failure Detection]
    PROMOTE[Promote Replica]
    SWITCH[Redirect Traffic]
    RESTORE[Restore Replication]
end

U --> DNS
DNS --> AKS
DNS --> GKE

AKS --> DB1
GKE --> DB2

DB1 -. Replication .-> DB2

MON1 --> FAIL
FAIL --> PROMOTE
PROMOTE --> SWITCH
SWITCH --> DNS

RESTORE --> DB1
DB2 -. Rebuild Replica .-> DB1
```

## Recovery Procedure

### Step 1 --- Confirm Primary Failure

``` bash
kubectl get nodes
kubectl get pods -A
```

Verify DB:

``` bash
nc -zv DB_HOST 5432
```

------------------------------------------------------------------------

### Step 2 --- Promote Replica

Example:

``` bash
gcloud sql instances promote-replica SECONDARY_DB
```

PostgreSQL:

``` sql
SELECT pg_promote();
```

Validate:

``` sql
SELECT pg_is_in_recovery();
```

Expected:

``` text
false
```

------------------------------------------------------------------------

### Step 3 --- Redirect Traffic

``` bash
kubectl set env deployment/api DATABASE_HOST=db-gcp-primary
kubectl rollout restart deployment/api
```

------------------------------------------------------------------------

### Step 4 --- Validate Recovery

``` bash
curl /health
kubectl get pods
```

------------------------------------------------------------------------

## Failback

1.  Restore original cluster
2.  Configure replication
3.  Synchronize
4.  Validate
5.  Execute controlled failback

## Targets

  Metric   Target
  -------- ---------------
  RTO      \< 15 minutes
  RPO      \< 5 minutes

## Runbook Checklist

-   Confirm outage
-   Promote replica
-   Redirect traffic
-   Validate services
-   Restore replication
