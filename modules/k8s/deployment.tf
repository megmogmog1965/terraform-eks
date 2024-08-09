resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx-deployment"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        termination_grace_period_seconds = 86400

        container {
          name  = "nginx"
          image = "node:18"

          working_dir = "/app"
          command = ["/bin/sh"]
          args = ["-c", "cd /app && cp /usr/src/app/index.js . && npm install express && exec node ./index.js"]

          resources {
            requests = {
              cpu    = "128m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "256m"
              memory = "512Mi"
            }
          }

          port {
            container_port = 3000
          }

          volume_mount {
            name       = "express-app-code"
            mount_path = "/usr/src/app"
          }
        }

        volume {
          name = "express-app-code"

          config_map {
            name = kubernetes_config_map.express_app_config.metadata[0].name

            items {
              key  = "index.js"
              path = "index.js"
            }
          }
        }
      }
    }
  }
}

# Kubernetes ConfigMap
resource "kubernetes_config_map" "express_app_config" {
  metadata {
    name = "express-app-config"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    "index.js" = <<EOL
const express = require("express")
const app = express()

const TERMINATE_TIMEOUT_MINUTES = 120

const server = app.listen(3000, function(){
    console.log("Node.js is listening to PORT:" + server.address().port)
})

app.get("/", function(req, res, next){
    res.json({"hello": "world"})
})

process.on('SIGTERM', () => {
  let count = 0

  const intervalID = setInterval(() => {
    if (count++ < TERMINATE_TIMEOUT_MINUTES) {
      console.log(`waiting: ` + count + ` minutes`)
      return
    }

    server.close(() => {
      console.log('TERMINATED !!')
      clearInterval(intervalID)
      process.exit(0);
    })
  } , 1000 * 60)
})
EOL
  }
}
