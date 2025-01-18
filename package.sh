#!/bin/bash -e
# Copyright (c) 2025 Roger Brown.
# Licensed under the MIT License.

VERSION=$(xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' pom.xml)
ARTIFACTID=$(xmllint --xpath '/*[local-name()="project"]/*[local-name()="artifactId"]/text()' pom.xml)
RELEASE=1
PKGROOT=usr/share/sqlline
SPECFILE=$(pwd)/rpm.spec
TGTPATH=$(pwd)/rpm.dir
BASEDIR=$(pwd)/work/data

if test -z "$MAINTAINER"
then
	if git config user.email > /dev/null
	then
		MAINTAINER="$(git config user.email)"
	else
		echo MAINTAINER not set 1>&2
		false
	fi
fi

cleanup()
{
	if test -d work
	then
		chmod -R +w work
		rm -rf work
	fi
	rm -rf $TGTPATH $SPECFILE work rpms
}

trap cleanup 0

mvn clean

mvn package

ls -ld "target/$ARTIFACTID-$VERSION.zip"

mkdir -p "work/data/$PKGROOT"

(
	set -e
	cd "work/data/$PKGROOT"
	unzip "../../../../../target/$ARTIFACTID-$VERSION.zip"
	cp "../../../../../README.md" .
	mv "$ARTIFACTID-$VERSION/lib" lib
	mv "$ARTIFACTID-$VERSION/sqlline.jar" sqlline.jar
	rmdir "$ARTIFACTID-$VERSION"

	cat >sqlline <<EOF
#!/bin/sh -e
if test -n "\$JAVA_HOME"
then
	exec "\$JAVA_HOME/bin/java" -jar "/$PKGROOT/sqlline.jar" "\$@"
else
	exec java -jar "/$PKGROOT/sqlline.jar" "\$@"
fi
EOF

	chmod +x sqlline
)

case "$VERSION" in
	*-* )
		RELEASE=$(echo $VERSION | sed y/-/\ / | while read A B ; do echo $B; done )
		VERSION=$(echo $VERSION | sed y/-/\ / | while read A B ; do echo $A; done )
		;;
	* )
		;;
esac

(
	cd work
	echo 2.0 > debian-binary
	mkdir control
	
	SIZE=$( du -sk data | while read A B; do echo $A; done)

	cat > control/control <<EOF
Package: $ARTIFACTID
Version: $VERSION-$RELEASE
Architecture: all
Installed-Size: $SIZE
Maintainer: $MAINTAINER
Section: utils
Priority: extra
Description: Sqlline with a set of common drivers.
EOF

	for d in data control
	do
		(
			set -e

			cd "$d"

			tar --owner=0 --group=0 --create --gzip --file "../$d.tar.gz" $(find * -name control -type f) $(find * -name sqlline -type d)
		)
	done

	ar r "$ARTIFACTID"_"$VERSION-$RELEASE"_all.deb debian-binary control.tar.* data.tar.*

	mv *.deb ..
)

if rpmbuild --version 2>/dev/null
then
	(
		cat <<EOF
Summary: Sqlline with a set of common drivers.
Name: $ARTIFACTID
Version: $VERSION
Release: $RELEASE
Group: Development/Tools
License: MIT
Packager: $MAINTAINER
Autoreq: 0
AutoReqProv: no
Prefix: /$PKGROOT
BuildArch: noarch

%description
Simple packaging of sqlline with a set of common drivers

EOF

		echo "%files"
		echo "%defattr(-,root,root)"
		cd "$BASEDIR"

		find $PKGROOT/* | while read N
		do
			if test -L "$N"
			then
				echo "/$N"
			else
				if test -d "$N"
				then
					echo "%dir %attr(555,root,root) /$N"
				else
					if test -f "$N"
					then
						if test -x "$N"
						then
							echo "%attr(555,root,root) /$N"
						else
							echo "%attr(444,root,root) /$N"	
						fi
					fi
				fi
			fi
		done

		echo
		echo "%clean"
		echo echo clean "$\@"
		echo

	) > "$SPECFILE"

	rpmbuild --buildroot "$BASEDIR" --define "_rpmdir $PWD/rpms" -bb "$SPECFILE" --define "_build_id_links none" 

	find rpms -type f -name "*.rpm" | while read N
	do
		mv "$N" .
		basename "$N"
	done
fi
