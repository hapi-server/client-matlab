% Use to generate html/hapi_demo.html and ./hapi_demo.md
cd ..
clear opts
opts.figureSnapMethod = 'print';
opts.maxWidth = 800;
fname = publish('hapi_demo',opts);
web(fname);
[s,r] = system('cd html;/usr/local/bin/pandoc -s -r html -t markdown_github hapi_demo.html -o hapi_demo.md');
[s,r] = system('sed "s/hapi_demo_/html\/hapi_demo_/g" html/hapi_demo.md > hapi_demo.md');
[s,r] = system('sed -i "s/\.png)/.png)\n/" hapi_demo.md');