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
