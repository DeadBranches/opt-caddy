let base_id = 6660
let service = "caddy"

sudo groupadd -r -g ($base_id) $"svc-($service)"
useradd --system --uid ($base_id) --gid ($base_id) -c "service account" --shell /usr/sbin/nologin $"(service)"


# Used on certs directory
sudo groupmod -g ($base_id + 1)  $"certs-(service)"
sudo usermod --append --groups $"certs-($service)" $"svc-($service)"
