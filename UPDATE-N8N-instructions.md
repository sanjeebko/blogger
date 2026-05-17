# Update n8n to Version 2.4.6

The `docker-compose.yaml` file in this workspace has been updated to use `n8n/n8n:2.4.6`.

Since the n8n server is hosted on **192.168.0.169**, you need to apply this change on that server.

## Instructions

1.  **Transfer the updated `docker-compose.yaml`** to the server at `192.168.0.169` (if this workspace is not already mounted there).
    *   *Note: If Drive F: is mapped to that server, the file is already updated.*

2.  **Connect to the server** via SSH:
    ```powershell
    ssh sanjeeb@192.168.0.169
    ```

3.  **Navigate to the project directory** (e.g., `~/blogger` or where `docker-compose.yaml` is located).

4.  **Run the update commands**:
    ```bash
    # Pull the new image version
    docker-compose pull n8n

    # Recreate the container with the new image
    docker-compose up -d n8n
    ```

5.  **Verify the update**:
    ```bash
    docker ps | grep n8n
    # Should show n8nio/n8n:2.4.6
    ```
