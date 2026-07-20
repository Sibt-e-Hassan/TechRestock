# Shoppanda legal pages (Surge deployment)

Deploy the **privacy** and **terms** folders as separate Surge sites for Google Play–ready URLs.

## Deploy commands

```bash
# One-time: install Surge and log in
npm install -g surge
surge login

# From project root — deploy Privacy Policy
cd web_docs
surge privacy/ shoppanda-privacy.surge.sh

# Deploy Terms of Service (use a different subdomain)
surge terms/ shoppanda-terms.surge.sh
```

After deploy, update `lib/config/legal_urls.dart` if your subdomains differ.

## Play Console URLs

| Document        | Example URL                          |
|-----------------|--------------------------------------|
| Privacy Policy  | https://shoppanda-privacy.surge.sh   |
| Terms of Service| https://shoppanda-terms.surge.sh     |

Full policy text lives in `privacy/index.html` and `terms/index.html`.
