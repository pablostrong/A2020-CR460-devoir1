# instance 1
resource "google_compute_instance" "canard" {
  name         = "canard"
  machine_type = "f1-micro"
  zone         = "us-east1-b"
  tags         = ["public"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

network_interface {
    subnetwork = google_compute_subnetwork.prod-dmz.self_link
    access_config {
	   }
  }
  metadata_startup_script = "apt-get -y update && apt-get -y upgrade && apt-get -y install apache2 && systemctl start apache2"
}

# instance 2
resource "google_compute_instance" "mouton" {
  name         = "mouton"
  machine_type = "f1-micro"
  zone         = "us-east1-b"
  tags         = ["public"]

  boot_disk {
    initialize_params {
      image = "fedora-coreos-cloud/fedora-coreos-stable"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.prod-interne.self_link
    access_config {
	      }
     }
}

# instance 3
resource "google_compute_instance" "cheval" {
  name         = "cheval"
  machine_type = "f1-micro"
  zone         = "us-east1-b"
  tags         = ["traitement"]

  boot_disk {
    initialize_params {
      image = "fedora-coreos-cloud/fedora-coreos-stable"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.prod-traitement.self_link
    access_config {
	        }
  }
}

# instance 4
resource "google_compute_instance" "fermier" {
  name         = "fermier"
  machine_type = "f1-micro"
  zone         = "us-east1-b"
  tags         = ["fermier"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
        }
     }
  network_interface {
    network = "default"
    access_config {
	       }
       }
   }


# reseau principal
  resource "google_compute_network" "devoir1" {
    name                      = "devoir1"
	  auto_create_subnetworks   = "false"
}

# sous reseau 1
   resource "google_compute_subnetwork" "prod-interne" {
      name                        = "prod-interne"
      ip_cidr_range               = "10.0.3.0/24"
      region                      = "us-east1"
	    network                     = google_compute_network.devoir1.self_link
	}

 # sous reseau 2
   resource "google_compute_subnetwork" "prod-dmz" {
      name                        = "prod-dmz"
      ip_cidr_range               = "172.16.3.0/24"
      region                      = "us-east1"
	    network                     = google_compute_network.devoir1.self_link
	}

 # sous reseau 3
   resource "google_compute_subnetwork" "prod-traitement" {
      name                        = "prod-traitement"
      ip_cidr_range               = "10.0.2.0/24"
      region                      = "us-east1"
	    network                     = google_compute_network.devoir1.self_link
	}

# règles de parefeux #
resource "google_compute_firewall" "ssh-public" {
  name    = "ssh-public"
  network = google_compute_network.devoir1.self_link
   allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags=["public"]
}

resource "google_compute_firewall" "public-web" {
  name    = "public-web"
  network = google_compute_network.devoir1.self_link
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  target_tags=["public"]
}

resource "google_compute_firewall" "ssh-traitement" {
  name    = "ssh-traitement"
  network = google_compute_network.devoir1.self_link
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags=["traitement"]
}

resource "google_compute_firewall" "internal-control" {
  name    = "internal-control"
  network = google_compute_network.devoir1.self_link

  allow {
    protocol = "tcp"
    ports    = ["2846", "5462"]
  }

  source_ranges = ["10.0.3.0/24"]
  target_tags = ["backend"]
}
