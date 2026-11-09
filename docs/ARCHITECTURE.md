# 🏛️ Enterprise Azure Landing Zone — High-Level & Low-Level Architecture (HLD / LLD)

**Author:** Abhishek Chauhan  
**Standard:** Microsoft Cloud Adoption Framework (CAF) Enterprise-Scale  
**Target Availability:** 99.99% SLA  

---

## 1. Executive Summary

This architecture establishes an enterprise-grade cloud landing zone engineered according to Zero-Trust principles, Defense-in-Depth network segmentation, continuous compliance, multi-region disaster recovery, and FinOps guardrails.

---

## 2. Network Topology & Traffic Flow

### 2.1 Hub-and-Spoke Overview
- **Hub Virtual Network (10.0.0.0/16)**: Hosts centralized shared services, including:
  - **Azure Firewall Premium**: Central egress/ingress inspection with IDPS and TLS inspection.
  - **Azure Bastion Host**: Zero public IP jump-host management directly through the Azure portal.
  - **Azure Private DNS Zones**: `privatelink.*` zones linked to Hub and Spoke VNets.
  - **GatewaySubnet**: Reserved for ExpressRoute and VPN Gateways.
- **Spoke Virtual Networks**:
  - **Workload Spoke (10.1.0.0/16)**: Hosts containerized microservices and application tiers.
  - **Data Spoke (10.2.0.0/16)**: Hosts managed data services, storage accounts, and databases.

### 2.2 Forced Tunneling (UDR `0.0.0.0/0`)
All spoke subnets are bound to a User-Defined Route (UDR) table enforcing `0.0.0.0/0` with next-hop directed to the internal private IP of Azure Firewall (`10.0.1.4`). This guarantees that:
- Direct internet breakout is impossible from workload VMs or pods.
- All outbound traffic is subject to IDPS packet inspection and URL category filtering.
- Public IP attachments to workload NICs are automatically blocked via Azure Policy.

---

## 3. Zero-Trust Security Framework

| Security Layer | Implementation Component | Technical Specification |
|---|---|---|
| **Identity & Access** | Azure Active Directory & RBAC | Least-privilege role assignments, Just-In-Time (JIT) access via Bastion |
| **Secrets & Keys** | Azure Key Vault (Premium) | Hardware HSM backed, Purge Protection enabled, Soft-Delete 90 days |
| **Data at Rest** | Disk Encryption Set | Customer-Managed Keys (CMK) with RSA-4096 bit key size |
| **Threat Detection** | Defender for Cloud & Microsoft Sentinel | Continuous CSPM/CWPP, KQL incident correlation, automated SOC alerts |

---

## 4. Disaster Recovery & Business Continuity (BCDR)

- **Paired Regions**: Primary Region (**East US**) and Secondary Region (**Central US**).
- **Azure Site Recovery (ASR)**:
  - Protection containers replicated across regional fabrics.
  - Strict replication policy targeting **$\le$ 15-Minute RPO** (Recovery Point Objective) and **$\le$ 30-Minute RTO** (Recovery Time Objective).
- **Storage Durability**: RA-GRS (Read-Access Geo-Redundant Storage) ensuring data remains accessible during primary datacenter failure.
- **Global Traffic Routing**: Azure Traffic Manager / Front Door operating priority health probing with sub-30-second failover.

---

## 5. Continuous Observability

- **Central Log Analytics Workspace**: 90-day retention on hot analytical tier.
- **Application Insights**: Real-time distributed tracing, exception telemetry, and live metrics.
- **CloudOps Alerting**: Action groups dispatching to PagerDuty and incident channels upon critical metric degradation.

---

## 6. FinOps & Cost Optimization

- **Management Groups Hierarchy**: Segmenting subscriptions into Core Platform and Workload enclaves.
- **Resource Locks**: `CanNotDelete` locks deployed to core network and vault foundations.
- **Tiered Budgets**: Notifications triggered at 50%, 75%, 90%, and 100% of defined budget thresholds.
