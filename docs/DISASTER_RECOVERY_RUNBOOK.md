# ⚡ Disaster Recovery & Business Continuity (BCDR) Runbook

**Author:** Abhishek Chauhan  
**Target RPO:** &le; 15 Minutes  
**Target RTO:** &le; 30 Minutes  
**Paired Regions:** East US (Primary) &bull; Central US (Secondary)  

---

## 1. Failover Criteria & Trigger Mechanisms

A failover event is declared when:
- Continuous service disruption in **East US** exceeds 10 minutes with no estimated time of recovery (ETR) from Microsoft Azure Status.
- Azure Traffic Manager / Azure Front Door health probe reports consecutive failed checks ($> 2$ failures).
- PagerDuty CloudOps incident severity reaches P1/Sev-0.

---

## 2. Automated & Manual Failover Steps

### Step 1: Health Assessment & Decision Gate
```bash
# Verify Traffic Manager probe health
az network traffic-manager profile show \
  --name ent-lz-tm-global \
  --resource-group ent-lz-prod-primary-rg \
  --query "endpoints[].endpointMonitorStatus"
```

### Step 2: Trigger Azure Site Recovery (ASR) Unplanned Failover
```bash
# Execute multi-region failover from East US to Central US
az site-recovery protection-container failover \
  --recovery-vault-name ent-lz-rsv-backup \
  --resource-group ent-lz-prod-primary-rg \
  --container-name ent-lz-container-eastus \
  --failover-direction PrimaryToRecovery \
  --action Planned
```

### Step 3: Switch Storage DNS / RA-GRS Read Target
- Update application connection strings to the secondary endpoint:
  `<accountname>-secondary.blob.core.windows.net`

### Step 4: Validate Workload Health in Central US
- Test synthetic health endpoint: `https://ent-lz-centralus.internal.net/healthz`
- Confirm Log Analytics ingestion from the secondary region.

---

## 3. Post-Incident Reprotect & Failback

Once primary region stability is certified:
1. Re-enable reverse replication from **Central US** back to **East US**.
2. Synchronize delta data changes accumulated during failover.
3. Initiate scheduled maintenance window failback with zero data loss.
