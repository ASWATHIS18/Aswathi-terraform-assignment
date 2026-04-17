# Project Architecture & Communication Overview

This document provides a conceptual overview of the Terraform infrastructure we built, explaining how the components interact, their default behaviors, and the precise reasoning behind this design pattern.

---

## 1. The Network Boundary (VPC)
**What it is:** A Virtual Private Cloud (VPC) with a CIDR block of `10.0.0.0/16`.
**Default Nature:** Completely isolated from the rest of the world.
**Why we used it:** It acts as a secure, private boundary for your AWS resources. Building a custom VPC instead of using the default one ensures you have absolute control over the networking rules, allowing you to establish strict public/private separation.

---

## 2. The Internet Gateway & Public Subnet
**What it is:** An Internet Gateway (IGW) attached to a Public Subnet (`10.0.1.0/24`).
**Communication Flow:** The IGW acts as a two-way door. Traffic from the public internet can enter the VPC, and traffic from inside the subnet can exit to the internet.
**Why we used it:** We needed a place to host web-facing servers (like NGINX). By explicitly routing `0.0.0.0/0` (the entire internet) through the IGW via a Route Table, anything placed inside this subnet becomes internet-accessible.

---

## 3. The Public EC2 Instance (NGINX)
**Default Nature:** Highly accessible. Because its subnet relies on the IGW, AWS automatically attaches a Public IP to it on launch.
**Security Group Setup:** We attached `nginx-sg` which allows:
- **Port 80 (HTTP):** So the entire internet can view your NGINX website.
- **Port 22 (SSH):** So you can remotely log in via your terminal using your dynamically generated `terraform-key`.
**Why we used it:** This instance simulates a "Frontend Web Server". It MUST be in the public subnet because customers need to access the webpage. 

---

## 4. The NAT Gateway & Private Subnet
**What it is:** A Network Address Translation (NAT) Gateway sitting in the public subnet, connected to the Private Subnet (`10.0.2.0/24`).
**Communication Flow:** The NAT Gateway is a "one-way door". It allows machines *inside* the private subnet to reach out to the internet (outbound), but completely blocks the internet from reaching *in* (inbound).
**Why we used it:** If the backend machine needs to download a security patch, software update, or communicate with an external API, it routes its traffic through the NAT Gateway. The NAT Gateway masks the private machine's IP, goes to the internet to get the download, and privately hands it black to the machine.

---

## 5. The Private EC2 Instance
**Default Nature:** Completely invisible to the outside world. It has no Public IP address, making it impossible to be directly hacked from the open internet via SSH or HTTP.
**How it Communicates:** 
- To reach the internet: It sends a request to the NAT Gateway.
- To communicate with NGINX: It uses internal, secure AWS network paths (Private IPs).
**Why we used it:** This simulates a "Backend Server" or "Database". A database holds extremely sensitive information and should never be exposed to the public internet. By placing it in a private subnet, you ensure maximum security while still allowing the frontend NGINX server to securely talk to it behind the scenes. 

---

## 6. Remote State & Jenkins Pipeline
**Why we used it:** 
By configuring an **S3 Bucket** paired with a **DynamoDB Lock Table**, we successfully bridged the gap between local development and Jenkins automation. CI/CD pipelines (like Jenkins) clear their workspaces dynamically. If state was kept locally, Jenkins would forget what instances it created, resulting in zombie instances that charge your credit card without you knowing. 

Our remote backend explicitly solves this by keeping a permanent ledger of your infrastructure in the cloud so Jenkins can flawlessly track, plan, apply, and safely destroy the entire network!
