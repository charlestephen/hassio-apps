# Changelog

## 0.2.54

- Upgrading from upstream version 0.2.53 -> 0.2.54

> Upstream v0.2.54: https://github.com/Finsys/hawser/releases/tag/v0.2.54
>
> ## Changelog
> * 30cebed4342b16168572111854ebea93e0292c2e fix tasks/install.yml INJECT_FACTS_AS_VARS warning
> * fc3d00c3071c07497294fb2c530754ea6fd26562 honour HTTPS_PROXY/HTTP_PROXY for the edge dialer
> * 594004b0836d5ce42e3c7cdb3aac8f5187adebf4 remove a managed .env from the host when it is no longer sent

## 0.2.53

- First Home Assistant app release wrapping [Hawser](https://github.com/Finsys/hawser)
  `0.2.53`. Binary is baked into the image and tracked via `upstream_repo`.
- Edge and Standard modes, ingress status page, Docker socket access (Protection
  mode off required).

> Upstream v0.2.53: https://github.com/Finsys/hawser/releases/tag/v0.2.53
