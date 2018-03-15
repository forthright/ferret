Name:      ferret
Version:   #FERRET_VERSION#
Release:   1
Summary:   Open platform for continuous code analysis
Group:     Development/Tools
Vendor:    Forthright, Inc.
Packager:  Brent Lintner <brent.lintner@gmail.com>
License:   MPL-2.0
BuildArch: x86_64
URL:       https://github.com/forthright/ferret
AutoReq:   0

%description

%install
mkdir -p %{buildroot}/opt/ferret
mkdir %{buildroot}/opt/ferret/bin
mkdir %{buildroot}/opt/ferret/lib
cp -L README.md %{buildroot}/opt/ferret
cp -L CHANGELOG.md %{buildroot}/opt/ferret
cp -L LICENSE %{buildroot}/opt/ferret
cp -L bin/ferret %{buildroot}/opt/ferret/bin
cp -rL node_modules %{buildroot}/opt/ferret
cp -rL default %{buildroot}/opt/ferret
cp -rL lib/node %{buildroot}/opt/ferret/lib

%post
ln -s /opt/ferret/bin/ferret %{_bindir}/ferret

%postun
if [ $1 = 0 ]; then
  rm %{_bindir}/ferret
fi

%files
%defattr(-,root,root)

/opt/ferret
