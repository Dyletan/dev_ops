job "example"{
    datacenters=["dc1"]
    type="batch"

    group="example-group"{
        task "hello" {
            driver = "exec"

            config {
                command = "/bin/echo"
                args = ["Hello, world!"]
            }
        }
    }
}
