# Replication Package for the Paper "Cracks in The Stack: Hidden Vulnerabilities and Licensing Risks in LLM Pre-Training Datasets"

## Data

1. **b.[BATCH\*].gz**

   This file contains a list of SHA-1 hashes for blobs included in the random 1/128 sample from the Stack v2 dataset.

2. **b2obc.[BATCH].gz**

   This file contains the blobs that were associated with a commit pointing to an older version of the blob.

   **File format:**  
   `blob;oldBlob;commit`

3. **b2nbc.[BATCH].gz**

   This file contains the blobs that were associated with a commit pointing to a newer version of the blob.

   **File format:**  
   `blob;newBlob;commit`

4. **c2bnb.[BATCH].gz**

   This file contains the 1/128 random sample of commits in which a blob was updated to a newer version.

   **File format:**  
   `commit;blob;newBlob`

5. **b2ca.smol.gz**

   This file contains the complete list of blobs that have been fixed in association with a known CVE in the smol dataset.

   **File format:**  
   `blob;commit;CVE`

6. **Ptb2Pt**, **c2ch**, **p2P**, and **P2L**

   For more information about these datasets and how to access them, please visit: https://github.com/woc-hack/tutorial


\* **BATCH** can be `full` or `smol`.

## Scripts

1. **vulnerabilities.sh**

   Bash script used to process results section 1.

2. **noncompliance.sh**

   Bash script used to process results section 2.
