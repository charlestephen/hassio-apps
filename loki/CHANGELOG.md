# Changelog

## 3.7.10

- Upgrading from upstream version 3.7.9-1 -> 3.7.10

> Upstream v3.7.10: https://github.com/grafana/loki/releases/tag/v3.7.10
>
> ## [3.7.10](https://github.com/grafana/loki/compare/v3.7.9...v3.7.10) (2026-11-13)
>
>
> ### Features
>
> * **server:** Enable configurable TLS curve preferences [release-3.7.x] ([#25796](https://github.com/grafana/loki/issues/25796)) ([a297d55](https://github.com/grafana/loki/commit/a297d558eb0ca2d9f388d7f1a91dd3488bdb25aa))
>
>
> ### Bug Fixes
>
> * **deps:** Update github.com/grafana/gomemcache digest to 9448343 (release-3.7.x) ([#25608](https://github.com/grafana/loki/issues/25608)) ([a815365](https://github.com/grafana/loki/commit/a8153653b8c8610e8f07724785d62de1cd089046))
> * **deps:** Update github.com/grafana/jsonparser digest to 5f43846 (release-3.7.x) ([#25609](https://github.com/grafana/loki/issues/25609)) ([b85d0d2](https://github.com/grafana/loki/commit/b85d0d2a294e006897fe523e92f850834d78bdcd))
> * **deps:** Update github.com/joncrlsn/dque digest to 7723fd1 (release-3.7.x) ([#25387](https://github.com/grafana/loki/issues/25387)) ([ad44cbb](https://github.com/grafana/loki/commit/ad44cbb73b92ae4d6711e6a4acab23817104ed10))
> * **deps:** Update github.com/thanos-io/objstore digest to 72d3b9f (release-3.7.x) ([#25389](https://github.com/grafana/loki/issues/25389)) ([e7d6809](https://github.com/grafana/loki/commit/e7d68093e0be6cf96fdc81c801057beaca4f212d))
> * **deps:** Update k8s.io/utils digest to ca04ba5 (release-3.7.x) ([#25763](https://github.com/grafana/loki/issues/25763)) ([c405f19](https://github.com/grafana/loki/commit/c405f1942f4f3a944201f84b0d3d0d1418cdb9eb))
> * **deps:** Update module charm.land/bubbletea/v2 to v2.1.0 (release-3.7.x) ([#25836](https://github.com/grafana/loki/issues/25836)) ([72a947a](https://github.com/grafana/loki/commit/72a947ab733e87a13aaa3851213ad986e0acec62))
> * **deps:** Update module charm.land/bubbletea/v2 to v2.1.1 (release-3.7.x) ([#26025](https://github.com/grafana/loki/issues/26025)) ([1115cdc](https://github.com/grafana/loki/commit/1115cdcc02d6c3f5baa0c867e485164adbffe6d5))
> * **deps:** Update module charm.land/lipgloss/v2 to v2.0.6 (release-3.7.x) ([#25512](https://github.com/grafana/loki/issues/25512)) ([22f7483](https://github.com/grafana/loki/commit/22f7483ab43603238cda7927adff5b340c9af601))
> * **deps:** Update module cloud.google.com/go/storage to v1.70.0 (release-3.7.x) ([#25851](https://github.com/grafana/loki/issues/25851)) ([c10c38b](https://github.com/grafana/loki/commit/c10c38bac4736d05559d0e6ca8d27f86ad0fb4dd))
> * **deps:** Update module github.com/axiomhq/hyperloglog to v0.3.0 (release-3.7.x) ([#25860](https://github.com/grafana/loki/issues/25860)) ([89dba14](https://github.com/grafana/loki/commit/89dba147df26dea2cba238d7790acfcff877e20a))
> * **deps:** Update module github.com/bmatcuk/doublestar/v4 to v4.10.3 (release-3.7.x) ([#25519](https://github.com/grafana/loki/issues/25519)) ([726f181](https://github.com/grafana/loki/commit/726f181be6cd65bc69d775c1d6ee40fb9ec9c51a))
> * **deps:** Update module github.com/bmatcuk/doublestar/v4 to v4.10.4 (release-3.7.x) ([#25807](https://github.com/grafana/loki/issues/25807)) ([e8545f9](https://github.com/grafana/loki/commit/e8545f9ed7d9543ecf4b98c5a66c986ab7414eb6))
> * **deps:** Update module github.com/buger/jsonparser to v1.6.1 (release-3.7.x) ([#25861](https://github.com/grafana/loki/issues/25861)) ([d909e3a](https://github.com/grafana/loki/commit/d909e3aa62219071c6efd26830173ef923e72dc5))
> * **deps:** Update module github.com/grpc-ecosystem/go-grpc-middleware/v2 to v2.3.4 (release-3.7.x) ([#25522](https://github.com/grafana/loki/issues/25522)) ([80ba07a](https://github.com/grafana/loki/commit/80ba07a114cd16a49523043a340c500c9ad9185f))
> * **deps:** Update module github.com/hashicorp/consul/api to v1.35.0 (release-3.7.x) ([#25867](https://github.com/grafana/loki/issues/25867)) ([015fb4b](https://github.com/grafana/loki/commit/015fb4b44294578b073e10efe02e027eaf1daba9))
> * **deps:** Update module github.com/heroku/x to v0.7.0 (release-3.7.x) ([#25868](https://github.com/grafana/loki/issues/25868)) ([2341919](https://github.com/grafana/loki/commit/2341919b6b1a8822e897d0df6c397af756ae5d34))
> * **deps:** Update module github.com/IBM/go-sdk-core/v5 to v5.25.1 (release-3.7.x) ([#25869](https://github.com/grafana/loki/issues/25869)) ([c3da55b](https://github.com/grafana/loki/commit/c3da55b2f7db91a2fc7401d4a114224bfb8f2565))
> * **deps:** Update module github.com/IBM/go-sdk-core/v5 to v5.25.2 (release-3.7.x) ([#26062](https://github.com/grafana/loki/issues/26062)) ([4fc56e9](https://github.com/grafana/loki/commit/4fc56e9ba6eee7309e0ecd5022ccd93a0dd42eb9))
> * **deps:** Update module github.com/klauspost/pgzip to v1.2.7 (release-3.7.x) ([#25523](https://github.com/grafana/loki/issues/25523)) ([bd236c8](https://github.com/grafana/loki/commit/bd236c85f8a8bda681ca5425c9b48657097f795f))
> * **deps:** Update module github.com/klauspost/pgzip to v1.3.0 (release-3.7.x) ([#25877](https://github.com/grafana/loki/issues/25877)) ([5155c7a](https://github.com/grafana/loki/commit/5155c7a9b482a27f4a2351ab33fee0988c1608f1))
> * **deps:** Update module github.com/leodido/go-syslog/v4 to v4.6.0 (release-3.7.x) ([#25878](https://github.com/grafana/loki/issues/25878)) ([b2917b5](https://github.com/grafana/loki/commit/b2917b587b0cf0bc74528e164ad172a6128a11c9))
> * **deps:** Update module github.com/oklog/ulid/v2 to v2.1.2 (release-3.7.x) ([#25525](https://github.com/grafana/loki/issues/25525)) ([b48845c](https://github.com/grafana/loki/commit/b48845cf6af23fc1590832d7cafd23a53d7f0469))
> * **deps:** Update module github.com/oschwald/geoip2-golang/v2 to v2.5.0 (release-3.7.x) ([#25885](https://github.com/grafana/loki/issues/25885)) ([9b3b304](https://github.com/grafana/loki/commit/9b3b3042997dc9b0a423a22de43e5d605a419314))
> * **deps:** Update module github.com/pierrec/lz4/v4 to v4.1.33 (release-3.7.x) ([#25528](https://github.com/grafana/loki/issues/25528)) ([cc71cda](https://github.com/grafana/loki/commit/cc71cdace45640cc6ad6a2295fb127dd5592cb13))
> * **deps:** Update module github.com/pierrec/lz4/v4 to v4.1.33 (release-3.7.x) ([#25587](https://github.com/grafana/loki/issues/25587)) ([82dfca9](https://github.com/grafana/loki/commit/82dfca9d41d6dbf6b30890b5660e7a81dbdf8a27))
> * **deps:** Update module github.com/prometheus/common to v0.72.1 (release-3.7.x) ([#25799](https://github.com/grafana/loki/issues/25799)) ([d81da23](https://github.com/grafana/loki/commit/d81da239370cad1faeb5b7e79f46f2f7716090b6))
> * **deps:** Update module github.com/redis/go-redis/v9 to v9.23.0 (release-3.7.x) ([#25895](https://github.com/grafana/loki/issues/25895)) ([25256ba](https://github.com/grafana/loki/commit/25256ba7bcc2eadeba43e427aee3be5de27aa9b8))
> * **deps:** Update module github.com/schollz/progressbar/v3 to v3.19.1 (release-3.7.x) ([#25530](https://github.com/grafana/loki/issues/25530)) ([80841c3](https://github.com/grafana/loki/commit/80841c35941fc3e1eea5cacf8e43fb295f71ef4f))
> * **deps:** Update module github.com/shirou/gopsutil/v4 to v4.26.10 (release-3.7.x) ([#26049](https://github.com/grafana/loki/issues/26049)) ([4d5820a](https://github.com/grafana/loki/commit/4d5820af57116bcf0de41ffd83e82857addbf35d))
> * **deps:** Update module github.com/shirou/gopsutil/v4 to v4.26.9 (release-3.7.x) ([#25532](https://github.com/grafana/loki/issues/25532)) ([f5b2cfd](https://github.com/grafana/loki/commit/f5b2cfd1678e8a0e2c26e5d963e125c14e319fef))
> * **deps:** Update module github.com/stretchr/testify to v1.12.1 (release-3.7.x) ([#25902](https://github.com/grafana/loki/issues/25902)) ([418d8c5](https://github.com/grafana/loki/commit/418d8c58eb6b93225b859f8f52f9c7cdf4992bdb))
> * **deps:** Update module github.com/twmb/franz-go/pkg/kadm to v1.18.0 (release-3.7.x) ([#25903](https://github.com/grafana/loki/issues/25903)) ([aac2bf8](https://github.com/grafana/loki/commit/aac2bf8eb699dfddef9d35d9ccf59b930280ee16))
> * **deps:** Update module github.com/twmb/franz-go/plugin/kotel to v1.7.1 (release-3.7.x) ([#25909](https://github.com/grafana/loki/issues/25909)) ([cea4360](https://github.com/grafana/loki/commit/cea4360164e5ad30aa678efa62bda3be61adadab))
> * **deps:** Update module github.com/Workiva/go-datastructures to v1.1.8 (release-3.7.x) ([#25533](https://github.com/grafana/loki/issues/25533)) ([724235f](https://github.com/grafana/loki/commit/724235f29c76a1c175530e5615f25d7123e46fbb))
> * **deps:** Update module go.uber.org/atomic to v1.12.0 (release-3.7.x) ([#25913](https://github.com/grafana/loki/issues/25913)) ([8076082](https://github.com/grafana/loki/commit/8076082e8de1568c8d3819fa8ab748a46880dce9))
> * **deps:** Update module go.yaml.in/yaml/v3 to v3.0.6 (release-3.7.x) ([#26094](https://github.com/grafana/loki/issues/26094)) ([ad9545c](https://github.com/grafana/loki/commit/ad9545cbf812badbb2c740d5a5b311c000c0de12))
> * **deps:** Update module google.golang.org/api to v0.309.0 (release-3.7.x) ([#25914](https://github.com/grafana/loki/issues/25914)) ([d27157a](https://github.com/grafana/loki/commit/d27157a2d9f4b84c05aae9b3270b9c88410a613f))
> * **deps:** Update module google.golang.org/api to v0.310.0 (release-3.7.x) ([#26051](https://github.com/grafana/loki/issues/26051)) ([88b1615](https://github.com/grafana/loki/commit/88b161584bb8598741a41889f7c020d8ad10b3a8))
> * **deps:** Update module google.golang.org/grpc to v1.85.0 (release-3.7.x) ([#26006](https://github.com/grafana/loki/issues/26006)) ([e302417](https://github.com/grafana/loki/commit/e302417a683d9dd8e5adfa8a23123450941853ee))
> * **deps:** Update module k8s.io/apimachinery to v0.37.2 (release-3.7.x) ([#26026](https://github.com/grafana/loki/issues/26026)) ([e88b6d2](https://github.com/grafana/loki/commit/e88b6d28962036f369f6a6884fe7e62e04b39081))
> * Disable Multipath TCP on listeners by default ([#26093](https://github.com/grafana/loki/issues/26093)) ([#26117](https://github.com/grafana/loki/issues/26117)) ([e875f4e](https://github.com/grafana/loki/commit/e875f4e07b2c43ae7c93a22cccedceb58d667c72))
> * **helm:** Discard the Infos return value from the canary Prometheus query [release-3.7.x] ([#25832](https://github.com/grafana/loki/issues/25832)) ([c853ea7](https://github.com/grafana/loki/commit/c853ea786ccff52fba5ba8b913df8cce1d4884a9))
> * **ingester:** Stop the autoforget goroutine when the ingester stops [release-3.7.x] ([#25730](https://github.com/grafana/loki/issues/25730)) ([5c5cd03](https://github.com/grafana/loki/commit/5c5cd03a318df42313840e3580a9a8d77927f550))
> * **logql:** Skip every new series once the Logs Drilldown series limit trips [release-3.7.x] ([#26433](https://github.com/grafana/loki/issues/26433)) ([58aa5b3](https://github.com/grafana/loki/commit/58aa5b3be1f26719c6df51d7984869596677e354))
> * **loki:** Resolve deadlock on shutdown when the internal server is enabled [release-3.7.x] ([#25721](https://github.com/grafana/loki/issues/25721)) ([54d87da](https://github.com/grafana/loki/commit/54d87da6b638b4be47cb2555ad9b4dc11c78bffc))
> * **security/UNKNOWN/pkg/push:** Update module golang.org/x/net to v0.62.0 [SECURITY] (release-3.7.x) ([#25844](https://github.com/grafana/loki/issues/25844)) ([a0ffffb](https://github.com/grafana/loki/commit/a0ffffbf592eb55c2a7d6114706d9a660be4be21))
> * **security/UNKNOWN/:** Update module golang.org/x/crypto to v0.59.0 [SECURITY] (release-3.7.x) ([#26422](https://github.com/grafana/loki/issues/26422)) ([8221174](https://github.com/grafana/loki/commit/82211748ceed8ba18611e23f1ffb681a97cf1597))
>
>
> ### Reverts
>
> * Disable Multipath TCP on listeners by default ([#26236](https://github.com/grafana/loki/issues/26236)) ([6c8bbad](https://github.com/grafana/loki/commit/6c8bbad4aaa9b830e77e2968bcdde0e0299f13c0))

## 3.7.9-1

- First release: Loki 3.7.9 in single-binary mode with filesystem storage under `/data/loki`.
