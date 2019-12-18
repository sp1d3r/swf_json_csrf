## Purpose
This repository was created to simplify the SWF-based JSON CSRF exploitation. It should work also with XML (and any other) data using optional parameters. Also it can be used for easy exploitation of crossdomain.xml misconfiguration (no need to compile .swf for each case).

## Updates
Still working in:

| Browser  | Version |
| ------------- | ------------- |
| Chrome (with flash enabled)  | 79.0.3945.88 (last tested)  |


Starting with Chrome 62, direct link to SWF file may not work. If this behavior happens, use HTML wrapper. Also it will require from the victim to click on the flash container first time to enable it, lowering impact due to the user interaction factor.

**01.01.2018** - added HTML wrapper (`read.html`, should be used with `test.swf`) for better experience with Chrome. Usage and parameters are same as in case with test.swf. It supports also insecure crossdomain.xml exploitation (able to show the response from the target endpoint).

**25.03.2018** - added UI wrapper for better experience (`ui.html` + assets folder)

![ui](https://user-images.githubusercontent.com/24297694/37878674-5c3af75a-3075-11e8-80d6-66e2dd4dee6f.JPG)

**July 2018** - Fixed in the Firefox: https://www.mozilla.org/en-US/security/advisories/mfsa2018-15/#CVE-2018-12364

**July 2019** - Fix bypass (via 308 redirect) fixed in the Firefox: https://www.mozilla.org/en-US/security/advisories/mfsa2019-21/#CVE-2019-11712

**August 2019** - Flash was disabled by default in latest Chrome 76 builds

## Variations of target configuration
1) Target site has no crossdomain.xml, or secure crossdomain.xml, not allowing domains you can control. In this case you can't get the response from target site, but still can conduct CSRF attacks with arbitrary Content-Type header, if CSRF protection relies only on the content-type (e.g. checking it for being specific type). In this case usage of 307 redirect is required, to bypass crossdomain.xml (it will be requested only after the csrf will take place).
2) Target site has misconfigured crossdomain.xml, allowing domains you can control. In this case you can conduct both CSRF and response reading attacks. Usage of 307 redirect is not required.

## Instructions
The .swf file take 3 required and 2 optional parameters:
1) **jsonData** - apparently, JSON Data:) Can be other type of data, if optional `ct` param specified. Can be empty
2) **php_url** - URL of the 307 redirector php file. Can be empty (in this case SWF will request endpoint without 307 redirect - and likely will fail, if crossdomain.xml is secure, or not exist). You can implement your own redirector (not PHP), for example, if you are using different environment.
3) **endpoint** - target endpoint, which is vulnerable to CSRF, or, if you're exploiting insecure crossdomain.xml, URL which response you want to read.
4) **ct** (optional) - specify your own Content-Type. Without this parameter it will be `application/json`
5) **reqmethod** (optional) - specify your own request method. Without this parameter it will be `POST`

### Old way
Place test.swf and test.php on your host, then simply call the SWF file with the correct parameters.

**(As mentioned by [@ziyaxanalbeniz](https://twitter.com/ziyaxanalbeniz)) - we actually don't need crossdomain.xml from this repo, if test.php and test.swf are on same domain). Place it on your host if you also testing locally or across different domains.**

Example call (outdated way, direct request to the SWF):
```
http[s]://[yourhost-and-path]/test.swf?jsonData=[yourJSON]&php_url=http[s]://[yourhost-and-path]/test.php&endpoint=http[s]://[targethost-and-endpoint]
```
e.g.
https://example.com/test.swf?jsonData={"test":1}&php_url=https://example.com/test.php&endpoint=https://sometargethost.com/endpoint

Note, if your request is very complex (consist with many params, special characters, etc), you may need to figure correct url-encoding for jsonData and endpoint parameters (Action Script code used in SWF doesn't implement URL encoding/decoding, this task is moved to the researcher's side). I recommend to use HTML wrappers in this case.

### Preferred way - less bugs, less encoding problems, better compability with browsers
Using HTML wrapper - ui.html (handy UI, can be used for debugging) or read.html with test.swf, parameters are same:

https://example.com/read.html?jsonData={"test":1}&php_url=https://example.com/test.php&endpoint=https://sometargethost.com/endpoint

You can modify HTML/JS code in the wrappers for your needs (add encoding, etc) same as 307 redirect script.

In case your target has crossdomain.xml misconfigured, or allowing your domain, you will also get the response using this wrapper. In this case you can use wrapper without 307 redirect (no need of `php_url` parameter).
This is useful for Chrome >=62, where you can't access SWF directly, or if you want to exploit insecure crossdomain.xml. Note: if you are exploiting insecure crossdomain.xml, if the target site uses `https`, your origin should also use https for successful response reading.

If you have the questions regarding this repository - ping me in the Twitter: [@h1_sp1d3r](https://twitter.com/h1_sp1d3r)

## Example cases (CSRF)
1) Exploit JSON CSRF, POST-based, 307 redirect:
```
https://example.com/read.html?jsonData={"test":1}&php_url=https://example.com/test.php&endpoint=https://sometargethost.com/endpoint
```
2) Exploit XML CSRF, POST-based, 307 redirect:
```
https://example.com/read.html?jsonData=[xmldada]&php_url=https://example.com/test.php&endpoint=https://sometargethost.com/endpoint&ct=application/xml
```
## Example cases (read responses using insecure crossdomain.xml)
3) Exploit insecure crossdomain.xml (read data from target), GET-based, no 307 redirect:
```
https://example.com/read.html?jsonData=&endpoint=https://sometargethost.com/endpoint&reqmethod=GET
```
4) Exploit insecure crossdomain.xml (read data from target), POST-based, any content-type supported, no 307 redirect:
```
https://example.com/read.html?jsonData=somedata&endpoint=https://sometargethost.com/endpoint&ct=text/html
```


## Cross Browser Testing

This project is tested on following browsers as follows:

![1x](https://user-images.githubusercontent.com/24297694/31861974-dd74a5ce-b73e-11e7-8546-49e1fa29e991.JPG)

Notes: ✓ - Works, X - doesn't work


## Thanks
Special thanks to the [@emgeekboy](https://twitter.com/emgeekboy), who inspired me to make this repository and most functionality, and [@hivarekarpranav](https://twitter.com/hivarekarpranav), who did the cross-browser and request methods research.
Related blog posts about this: 
* http://www.geekboy.ninja/blog/exploiting-json-cross-site-request-forgery-csrf-using-flash/
* http://research.rootme.in/forging-content-type-header-with-flash/
* http://resources.infosecinstitute.com/bypassing-csrf-protections-fun-profit/#gref
* https://medium.com/@know.0nix/bypassing-crossdomain-policy-and-hit-hundreds-of-top-alexa-sites-af1944f6bbf5 - thanks to the [@knowledge_2014](https://twitter.com/knowledge_2014), who inspired me to implement the response reading component

Thanks for the contribution/bug reporting: [@nirvana-msu](https://github.com/nirvana-msu), [@snooze6](https://github.com/snooze6)

## Disclaimer
This repository is made for educational and ethical testing purposes only. Usage for attacking targets without prior mutual consent is illegal.
By using this testing tool you accept the fact that any damage (dataleak, system compromise, etc.) caused by the use of this tool is your responsibility.

## FAQ
1. Can we read response from server?

 Answer: no. Because of SOP. Still, if crossdomain.xml on the target host exist, and misconfigured - in this case yes.
 
2. Does it work with requests other than GET/POST?

 Answer: no.
 
3. Does it possible to craft custom headers like X-Requested-With, Origin or Referrer?

 Answer: no (it was possible in the past, but not now).

## Commits, PRs and bug reports are welcome!
