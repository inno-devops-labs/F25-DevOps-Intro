# Task 1 — First GitHub Actions Workflow

- **Workflow link**: [Successful Run](https://github.com/Ily17as/F25-DevOps-Intro/actions/runs/17879055175/job/50844422857)
- **Key Concepts Learned**:
  - **Jobs**: Define what is executed within the process. In this case, there is only one job — `run_on_push`, which runs on Ubuntu.
  - **Steps**: These are individual steps within a job, such as `actions/checkout@v2` for checking out code and steps for displaying system information.
  - **Triggers**: Conditions that initiate the workflow. In this case, the workflow is triggered by a push to the `main` branch and manually via `workflow_dispatch`.

- **What triggered the run**: The workflow was triggered by a push to the `main` branch.

# Task 2 — Manual Trigger + System Information

- **Manual Trigger**: The workflow can be triggered manually via the GitHub interface (Actions → Run workflow).
- **System Information**:
  - **Operating System**: Linux runnervmf4ws1 6.11.0-1018-azure #18~24.04.1-Ubuntu SMP Sat Jun 28 04:46:03 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux
  - **CPU Info**:
    - **Architecture**: x86_64
    - **CPU model**: AMD EPYC 7763 64-Core Processor
    - **Cores**: 2 cores per socket, 4 total CPUs
    - **CPU Threads**: 2 threads per core
    - **CPU Flags**: Includes features like AVX, AES, FMA, and more.
    - **Virtualization**: AMD-V, Hypervisor vendor: Microsoft
  - **Memory Info**:
    - **Total Memory**: 15 GiB
    - **Used Memory**: 986 MiB
    - **Free Memory**: 13 GiB
    - **Swap Memory**: 4.0 GiB (none used)

- **Vulnerabilities**: 
  - **Spectre v1 & v2**: Mitigated via techniques like Retpolines and barriers.
  - **Meltdown**: Not affected.
  - **Other vulnerabilities**: The system is unaffected by other vulnerabilities like MDS, L1TF, and others.
