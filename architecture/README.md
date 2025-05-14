# Architecture Overview

This folder contains the high-level architecture diagram for the multi-tier serverbased application.

![Architecture](./Severbased.png)

### Layers:
- **Edge Layer**: CloudFront, WAF
- **Presentation Layer**: EC2 Instances (public subnet)
- **Business Logic Layer**: EC2 Instances (private subnet)
- **Database Layer**: DocumentDB and Replica

### Monitoring:
- Integrated with **CloudWatch**, **Prometheus**  and **Grafana**
