/**
 * @author Attila Večerek <xvecer17@stud.fit.vutbr.cz>
 */
var less = require('less')
    , fs = require('fs')
    , path = require('path');

Less = {
    parse: function(src, isStdin) {
        // Parses a Less file and outputs its AST

        var visit = function(o) {
            // Attaches the node type to the necessary objects
            for (var p in o) {
                if (typeof o[p] == 'object') visit(o[p]);
            }
            if (o != null && o != "") {
                if ("type" in o) o["class"] = o.type;
            }
        };

        var code = src;
        var options = {};

        if (!isStdin) {
            code = fs.readFileSync(src, 'utf8').toString();
            options = {
                filename: path.resolve(src)
            }
        }

        return less.parse(code, options, function(e, tree) {
            if (!e) {
                visit(tree);
                console.log(JSON.stringify(tree, null, 2));
            } else {
                e.class = "error"
                console.log(JSON.stringify(e));
            }
        });
    }
};

if (process.argv[2] === "-stdin") {
    Less.parse(process.argv[3], process.argv[2]);
} else {
    Less.parse(process.argv[2]);
}
