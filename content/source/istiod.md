---
title: istiod 启动流程
type: book
date: "2021-01-28"
weight: 3
---

## istiod

main 函数很简单 (`pilot/cmd/pilot-discovery/main.go`):

``` go
func main() {
	if err := rootCmd.Execute(); err != nil {
		log.Error(err)
		os.Exit(-1)
	}
}
```

执行命令启动 istiod，失败如果就报错退出。跳转 `rootCmd` 可以看到是一个全局变量:

``` go
	rootCmd = &cobra.Command{
		Use:          "pilot-discovery",
		Short:        "Istio Pilot.",
		Long:         "Istio Pilot provides fleet-wide traffic management capabilities in the Istio Service Mesh.",
		SilenceUsage: true,
	}
```

istio 使用了 [cobra](https://github.com/spf13/cobra) 作为 cli 库，通常也是大多其它 golang 程序的选择。命令名称是 `pilot-discovery` (与编译出来的二进制相同，这也是 "潜规则")，但它最核心的还是它的一个叫 `discovery` 的子命令: 

``` go
	rootCmd.AddCommand(discoveryCmd)
```

这也是我们常说的 istiod，来看看它是如何定义的:

``` go
	discoveryCmd = &cobra.Command{
		Use:               "discovery",
		Short:             "Start Istio proxy discovery service.",
		...		
		RunE: func(c *cobra.Command, args []string) error {
			...
			// Create the server for the discovery service.
			discoveryServer, err := bootstrap.NewServer(serverArgs)
			if err != nil {
				return fmt.Errorf("failed to create discovery service: %v", err)
			}
			...
			// Start the server
			if err := discoveryServer.Start(stop); err != nil {
				return fmt.Errorf("failed to start discovery service: %v", err)
			}
		},
	}
```

istiod 启动时会执行 `RunE` 函数中的代码，可以看到核心是创建了一个 `discoveryServer` 并启动，来看看 `Start` 函数都做了些什么:

``` go
// Start starts all components of the Pilot discovery service on the port specified in DiscoveryServerOptions.
// If Port == 0, a port number is automatically chosen. Content serving is started by this method,
// but is executed asynchronously. Serving can be canceled at any time by closing the provided stop channel.
func (s *Server) Start(stop <-chan struct{}) error {
	log.Infof("Starting Istiod Server with primary cluster %s", s.clusterID)

	// Now start all of the components.
	for _, fn := range s.startFuncs {
		if err := fn(stop); err != nil {
			return err
		}
	}
	...
	if s.SecureGrpcListener != nil {
		go func() {
			log.Infof("starting secure gRPC discovery service at %s", s.SecureGrpcListener.Addr())
			if err := s.secureGrpcServer.Serve(s.SecureGrpcListener); err != nil {
				log.Errorf("error serving secure GRPC server: %v", err)
			}
		}()
	}

	if s.GRPCListener != nil {
		go func() {
			log.Infof("starting gRPC discovery service at %s", s.GRPCListener.Addr())
			if err := s.grpcServer.Serve(s.GRPCListener); err != nil {
				log.Errorf("error serving GRPC server: %v", err)
			}
		}()
	}
	...
	return nil
}
```

去除无关紧要的干扰，聚焦核心逻辑，可以看到主要是:
1. 启动所有内部组件。
2. 等都启动完成后就开始监听 gRPC 端口，也就是核心的 xDS 服务。

