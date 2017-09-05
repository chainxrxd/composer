ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ���Y �=�r�r�=��fRNR�TN�Oر���&93��|��ëh��x�d���C�q8��B�R�T>�T����<�;�y�/�E�$zw�~�HL�� ��L�Y�j��;�B���;F-�o��ѨL��c�0��BX��GbX��#�(�b�1�G@����c����m®f��[��W
]dZ6��3��Y��j*��9 O&�m�~3l���`�6�����Z6HY��A��jd����D��v�i[.I �ٖ�%l�?�X2����62�!R� xPN�>$
�\v��= ���D�W�Y��m�v���F6�A�����`���J�������0��Svs�O�TF��lZ�pP9*�S���J�uo.
C�	1ل��tw.���O�i�DL��D�M\�tt��n�uX55uQ�k�RM�Ci�*�#aVtŠ���M�x�u�E�-�?�z��&�5q�
��M&�FfQ����]���C�9,�YC&Qȥs<D}Z��S�fG��<�At��lǄ�0�)�ł^��X�և5,ZP�mur)Z��l����"\u�3��M����0�	�����Td(�3���9��v�=ͯ�>:Ȳ�J�c�L�3{�H�}��K���ß,;�[P�Tl��_��(8�=l�����:ttϐ��ԇfeҌ}�p��m�W���n�"��{o�:y�Xd��G����)eQ�=�{�d|��ߌ��q�p�p�j�j޵6����/J�;��$�2���,E���*��w��f���jrvL��s��ؿ�f�e�|�J(��僣R2�Vx?��&��tz5�)�AǐxDX���W3���>��Ϫ��z��X���3���l�ๅ�{i����s��DI�L�tm�Wt���r��5��!!E�B0�N�� ��LPfe�1�#k�9�4��M�A�"w�Iq;-t�nǼv;�օ6e�6ĊLD�k66������lo�;����.�<i:U�s�<��1֭ ��y;Q:v��MI��˟��ȰX�
њ&
H�=A"���h�Ϗ5<䲪c��6�T�[Xw�Z����0w�A������|�ѷF�Pu4����Ժ�o8z�=�AW�C������d"R��.J�O�`<8<D`��ƥ�>����>"�=�O=�!5���i��&��������)�v�.��O"O'�Iy�����?�	�^�;;�vڠ��:�F�����"`:����K!��+Y6�<��8�P�y���Dt,���iu�z��"� ��<޿�$� ���Gڣ�!i�z;< �K?�ؐw���d���F�&��Ks[/�N��I�f0� P���(f����ޒY Z��	�\6f�#�=�&�m9�n�Ek��1�]b�i�]��;�>3�l�s�2��:���}��=�"��)	�g26��4}s�	e�>�XQm�{�\��+:��*Q�k�|��M2P.wX���:�ґj�^SS� 3��x��h�<g�	�l��:9o�y���y���:m��?���+�F�6�������l2uz@�D����q�e��W�+0���l�YP�j�@k����O���~(���'�	k��
X��|�0C�GsyOm,�Q�b��/��W����øޙ{���h���O�z�3��s��͚��:i�iR
d� �6�\*W���儫�����R�3Y��WM��<���3x��jy���Ĝ��%�r3J��K~8N�ʹ����m���	�Y�1,d�$N��in�����k`�J�!�B�i�t+����#�,ݩ\�\QJ��\>}pT����,��xn!2Y5k�Z&j���/4�γ?���/���<��w��[�tf�;OM޿���9�sY��C`8�*2y����+��֥c����:��+2"~>�-q�qY����OJ����Jv6��0��X�[��[������e���4��� .���(L��pl�������ɧz}O�Nh�]�@�Du��8!�3�Y���sg���S����X��~��(�G �������g;�;I��矾\��J�����e�?B,<5��ptm�WS��t��7- ���K�15��^���ШYA����K�=��.vB?9&�Rrw�g���@��ŧD�O>&"d�M�f�����.�	}b�-�2"ܳ�<'¿�Ș~J�z�J��bA�>UB/Ǻ/�	37B�,R~��i�X�:����l��Y�\�_�#�ۄ{��bO!��Ʉ~k�E�����ke�0�:x�3]����8]���,`�Pu����[����w	
_f�c���O8L������p����G�j�p�?t�6ܵ���Q)�큻��a8�=�I<���@@
Aq�
o��"�{�
ޝ�[���Y�NTY<�7���,�����)^��J�����d��m�ѴA�gB�C?�'�����Q���J7����Z���9^����������n�lwf�O�T��l6 ��N��s@z�Y��~p�a:�rjg�@H�s+QF�&� ���ksZ��!T����?��A�x�Q=a����4�)Rf�%�r/ـQ���mb�v3�x �L!^Ύ�ud�%�L�4���5bFZ���@3�eL�>�!cV6��
c	0&�:�=����A>=X�6fyҔy	Rƒ��aA�G�����uui(c�	-b
��Id�?+�wc���1T��G�������}B�?�c��>�_�z�G���<�em�	^p�W�Ħ�"y�����k��������7�������Ô���'�
�,K�*����j]V���h��d)�,"9*ǫ�B9���jl+"U�"���������4�e�_��S:]#�qD6��o����m�ѷO9.����7�y㟸����__m��I"���7_���<�{����������w���?�.���ߜ�d�jZ�xL���/�)!m0��q~��ߌ��=�.�^���{�6n�����������sLޤ�%�t}��^����+o�5�5�n5�)�w�ԣ�&�K���A�n��<���t��߾�-�A��rl�c�	�(�V�V��
[��8��ruK��R��nՠ��eA��Vƫb�8��H�4��Ԯx�e�N� �N�B"��@2]��2��RI��wF>�KfϓIEM6�^.�4r%��ǅ�Z(���71�[z��l����Y��\Hܞz��'�VV�҉f>y|��H_*�D�pLHU��B������k��/2�ʑ�L����3-�}g��s*闧��E���q1p%����.��ٛf��&a��#�UI��M)���W�R����o����6�B���
�9)_�	��tB��Y�0,{g��'����KOS��b6�{}|t�������%�������YWmG:���I>Qt{~�/�3����K��OO"��M�z����Pz���IɆ'����/Gt���j�B�o��J⌌d"�M�?f�y9�4��d���K�*BNId����DQ̶.ʕ�1���
o�ӽ��M�q8)U^'v����qL/�Oឲ�����E��Y���*�c9+_;,E��t?���W*���"�� ��R�t"�+�9�m��<��R>�Է�ʹ���U-�+���=%�h�gЉ%r��;�,��z{폝6р<80�d&�פב]"�N^�~��&����G�\1)[{��;#�n|�VN��/㑓x�i����rT6N�z��n�j���^���5���L�z�x�)�3��w����r<֭�J��;��|�����`0��������׌��1c�?��S������(F��#��@�L�p�71��-{�+�O��w]�4�����V4�K�����?aQ����Vc~�a)wL��K����\>��%6YYd�Y��U,6!���O�a-�Z��c��@9��TȞ�zWϤ�zY�+��$.WRQJf7i�
�N��u���؋�c����*j<����Q�X��#E��w���H6O�#��ʁ�$�*�ԑ��O�V�F�|瓏9��]����_�2�|��G�����S��]_ã_���f��u�ϕ���?J����?��{����GR)�G!)����%c=3�I�J�u���,�nt�a;�����L��F�S:{�gJ�&�
>�{{��K۰ۆr��-�w!�w;F���)���3n��9�ܣ�ہO��~��4���5�}x�_	[������y��q5�$q�o���\"O��� Pt�h�J��E-�=�Q���7�}7�m�=˭k������ �5���@:0 �ꚡ��)\�Q]��.ف��Ѐ��ċZ��/���?��d�8��5� ���~�f� )܆����X�}�M)��R�,���EPE:�$����F`,��q�X��.�l�g�<ٹA���RL#�D���<��6�^F~$���-�F�ȠA�4��n�LG~&Yd���^D4�A��/\���L�ᬠ�ӣ�j�dr Op�cѐ���؃˥D�@��6z�j�K��úM/ B@ӄ}� -$|٦�,B;Ml���O۶4�A�{S��<}{2�q </���F����d�O��NQ�������{����$c�W6��%ꛌj��j��=���AL|S�!���'��MH���O��tgG�$�=1b���
;?�7W�~!/7m�^k 퓱�B�!���͘�}�I�KRs(��|	Ldu��u��>�h���ӳ_ǘ�imwR�>�Iɜ�_�+�3Np�Ŏ�c���Z~Sz�2�T�e�U�3��*4�_>��2���[_�k�{�{ѓ�HU��M�-%��$_�!��f��z�#��:��%:�-�Wk!7P��j�[K�O;��bw�b��#��\���(������K�j7�W�2_5t����M���M_�:��U�4٦��.}�*χs��P�&�����ڡ�ҁ�I�ێ��!���;�"�V���*��=oIw3Y��a�a�������U4�MVtB����ݞ��c̫X�5�#�INeb��m��\��þ"~�He��vȒ��c�N�`@0����`�td���E��ʄ�R�
���g�@�1�՘�}���bl�#�ݩ	Z������2�����GL��x�/��Ǿ'��QIZ������k�uK��=Msq7=Ej�A����F}��#��\���c'qn���dq��N��y�؉�,P�@H3�#�7�vĤ-`3!z�X�@����G��}W�֨sZ}�^����:�����`(�%��?���o�K�/�=�k�o���s�������_��7��k��q�s��,��8z����:��
�n]C���ga*Ɋ�I��"����p�)��B����12܊�BFe� ȶ�r���$��G�������7�����凟����}A�������!������}���V����﾿`���?x���{���!�5����������i���� 톋! -V h1e��
l���F��cCK�R
���&�ҧL�s���r�B��{�����«\p�CW5�e�
�ݨ*�%0#�5�:�M��i%ab��&�^}.�
��kHֳ����=C��0�/鴍@���V��`r��x����|��́��u3A�w)��Ek�Nq��6�q��΄b�L�0�)7g���A%\��f3Y�։�!M3فyX��g{��;�5��~���:�F�}��_���@Μw��s�0���X?ŗF�˗ٱ�k�A'r�B��:�7��2���J��9S��2ee$�R�-$0��,by��B�Z�Nr �Q�K[�#��$�$��ɚ0�hg.�4��-�1����)t����Gt��"n*���� i�I�;
S�_-2�a����71�lѪ�H��b�C�r�`��d�j��X͔��qg��r��/O3�N�OִV���Y�T6�tr�g�&%��Frʏ�C
m!Z�K��l~�]����t�%rW�%rW�%rW�%rW�%rW�%rW�%rW�%rW�%rW�%rW�%�py	c0�"o�R4x�$��?^�(%��cO�p���cLo�S�lӊ��b[���vV8�rr�D��A�C!U���A�ꉚ)��n����۩��?�n{���C������9Cd�x6d��FU,�zm��G�j���M��	����sS�<N��p�hjr,_���hl��6Y��V?��n�~"��>�ӱ0&!�2��-k9B�©�D��&ފ�<e���s�B���S�p,�#S.�|&;��ә2k&��j'�.Ȑ���d?�ӵL���Z6�'.�;��T�Q�MZyD�ڬ�����,J�K�̻��z�������oY��q�ڣ���-���
`�^�/���^	��g�{q�\l��a~���E���;G_�}���C��5�S�E/��7�@���˛�7�y��X�? ����� �o�@|�?�ƣ?u��?~�����z��ÿ�R�e��(������,'�*�g��,)�(��������u~��K�Ώ�|�2�`a9�,%r�Y���+���X�~Ʌآ�`rGt�Ʀ�	Lٕ�9 |�
L��H�L��(�Y)�aL��,�T��*0K<��L�8�>f�y%�+ 1*��N�� ��߬����o���E�M�����1o�i=ڮ.k�D����te�GM�&�9[�D���jY��I���d:u�N�t�o0"�i
�d�SP�8#5��@eh����v�8^9�D)9:�$�|���Q�J����>E�e'��Y��UZ�)�~��l�b�<TpLTj�p���,�F6т>��b!���Ƙ^`�8�e�J7�)Ǎ�0S�{�0����N|�ۿ�x�[W2M�M�P.��(ϗa��p�LN�L�����p�_����M9��+����]W?"W1�+r!��/�=n�e���6����3�{fVz\�ew���;m�]w�g��~��M��pĿ�\�C˞l�j5�7fI�g�D=���l���Ò�͠���Z(���2�g�S�(F�,1��\��<=���^mdi�T?�fNߡ�Z�M�P�lC9.дyj3K��L~Dw���@�:�|��$R�YGkO�#������Z�`��|�O��-U]�*,�.-H��V-�W����NU�bYs�Rd�F�P�7�yC�R�bQ��Ê�h2�l��)��"t�5\�W�u�~�1B��Q4�,<��M�WW�DV�d�R$Bv6(��552����RHزJ�&�_E22���H�	�~Ԑ��I*�G0�2AVv��D��c�2)s�U(��{�B)���B��:���uJ+�9$O�j��pI�?��:ݮ�Y�P�;�<Ǹ�ѱR=�������V.�*�dH[F�3�.��Qn�PW��P(�r�.������piJ
^ԇf�����y�S�y�� }),����)��f�R��;�4YhΧ8)W�tC�k��<O�HX#H���&��Q�1K�:6�MS`��QXbe��Bl4Z�X)�j9�2f�����.����,��.}7���t�
��x�2���|�B��K�C�-*�1Q��b�#7�_F~��*C}����xxySi#/�c�g�huK�R	�x�y���s���σ^�o!��<��()�n�M�b���S����Q�4U�}H���5�I\����)I!ki�3�*��i�8"�����8Xɐ�%��s:�Sw�V����G8�C��D�uE��Gȇ���)z��p/r/�r��f�wHwI����D��z�_�����Q�-��~�����r�@}�l?t\�:=	�j��@��kH7�˝AM%�@/�r�ke��G���aU�Ki��]�ȍ;��� �H;�q9#�O`�E�O�#c��gv��~��������?uް6�B_ː�K���<~�:����>����غ]�-z�:@N�J[Ŝ���Ɏv�l>P;������cu�euɆ���ãqя�E�#~?zX҂�c�|�� Sk��~��B-� �g�+bw��/��7���B;�z�M-�18��b�`��I0�A�;�jrp�X:
 ���T���Ԟ���pe Y|�B�Al��ja�C�٤�$����(�Џ�����p�Dd-:����>�����Z�i�zW�x��L����w��~t�W��"5�Z�,� ~Ҋ�y֫������U'.��&;��X2����ں���x��U��.�#��+b@}�&:���Y,@'�L-�q�Or+! l��D�Ա���#�F���������	�˭~f@�����9���O=����3[��\;ؐ��_����bS��_��,���UM��d����s��EC��ӡ#�-��6���҂��u�&����-o�C�b�$4`en��f#�O�(�-`��ɏ ��$~y���|.��t��qp��"(�fK�-�x�Kv��V�>aP�:W�&���+���h�R����E�<����v ����{���]�LR5�2�U�?��!��q_j�%v�4a� ��m{[�'<	^��v�O1��1��_i P�P�X�A?MI�#�T�l����Y�I���k)�΂�������2k��I .�rXǚF��A�.�����:�v5`U;V&k( ?��=n�ܩ�!c���5�SK��f��aM�=W���v� �p?2m��_Y�LTI��%�����ӕ�s��Zv�E���]Z_�b�F��ދ޿ �>��	p�mX���n�����!�"T�i|��U��m��j>���&�ĉ�3#��ON|-3�Q��Ú�C��y�M�$p��:��u_Eٜȝ <t�ϟ���Ñ�n��mm�i��<�@���#V��9�1��.���E�[@�BSv6��
t"��{��}���f*�9����n)�pḡ|zl?�@�)����1����Zl�X����:�����v��+۸��?!6���v8��G+��$��l�dG�[V�`j'��2�6<�{�	�)��8}"c<C���Ρ�K\���oYڪbGg��.+>�%��5_�Z���>+W4t��o֎D���T���&��D��٦�v���q9��%�h���c��l7�1J
���DPҙ޷P{���A�;�
|����n�I+��fl�7��z����(v,�7av�}eq�*�ԤH��lb�(�%'�p�b�$QT8�D�(UBRS!$��5�ј�(�DI�51�'M;��	�96�O�O�l�,�m����)z�sKBO�;g	��dg�=�]Tleܵ/�Y~G�+8vW���6Wd��E�I.���Y&��p.�LV��������ei�-r��3ZW؅���%�$pb*�>�G�Wd��^����.T���<�>��]�D����@�g]�\T���#;���:hg��P}�B;�ѝ6!-m��:Ӻ*v0:�2����m��6��ӵ���vn�(t�	�nus���w���KS.&��(��{<W� �'�l�,�q�B���)���s�*��,ǔ��Y+��e�9>+>���	����5:�&�d:tl����>aI���E������v�l£�;����U4�+��\6�'ϲ�X�Okt�\6:�_�]ot�u���L�S��<-��yt�c��"pl�*[i����H3t�{!OY���\9�bgL�_��S�X4�B�����Q��3{��䳶���,��/�7��]�����������͢��m7�o��-ۅ~Lv��
�.+ce(�g��;�ڼwI a�R�nm��\��
ɻc����p�8b��r1c5�8B
8*:�����n�߮l�n�%Lb�C��}�;��6��h�����w���H/|��d�m�?DD����#���I|��7v�����������t�������������B����*��6�?	��>Ҿ�?�y�'�����lڗ����/Nn~�����}/����������z��o��Qz%�?rG�������/�O�c��l+XkG�2nɎ0���v�l)�ԊE�xK��X�j��H�	G�&&+x��Zg�ˢίvz��!
߶����|��f����4��5uh�ÑVF��s�"��є�0p��Ns�|]W��ʌ���J�s�]�� ��R�9,�"ch$[\�O�Ѳ���m��!iY�����I)]�M:�⤫��Sf5IƻcTc/������_~z�������˗�66��yH��>��6��8u8��Gz�?��8���>Ҿ������W>��A�߿��:�##����G�g����=_�t������l������W@�ë� t8%�:�����w�OR��:��}�WK�C?��P��K�����?��%������>�!T�!T�!T�O4��N镰���g�ںE��;�b�;F����8�DDP�� "�@QQ~��$VuG��JU������RI):�k����`��?JA�_�A�_�������O�� ����?�V�:��v���C�o)x��7������)u�ޜe��~���!�-�\���,*��t!�����O�gv?��!z[����u����g�+�'�J�|����m�Y�8FO�].��Zh����v��f���.����$�4��sՑ�U�
�|��1G�vc�#��2��͏�2p��7Rs������'�#{���_m�L���^>���ۮ�C�󄤏�:N���f9��[�o�>��n�\9��0��H�#'�]QE#�:�����MiRh�C$��x8�G���ʆ叩O۽�~���4�eĜ��0����iP����P��� 
@5���k�Z�?��+C��R��F-���O8��]
 �	� �	򟪭��?�_����������_[�Ղ����
��Ԋ�����:��0�_ޜ��/������O�}�'{~F�f��>�$�o��oe����\׿���;�u���z��~��vR�!O|����p4�+=��{s;X��{T���.ѡU7��5�5r��
j�cb�I�f��3�7v~���І���SY����y�ϟ�z�y'@�y>מK�� ����i�#�>�{����Lu�kd�������Β�7�����|�O��`��TTTA->�{����Ùk��0d/WLt�aC͑u6U9��R\2ԇkcb���������?�_���[��l��B(�+ ��_[�Ձ��W�/����:��t�cL0��i��ؔb)�d)��8?DC�g}&�  h£� '� %:�����3~u��G��P���_���]W[�b!�7[M�F�$c���;�k�kǼ�h��m�+�K��ɲSks$�/�C��d�9��S�̻�n9>��c�I��!�َ��,�cIr�}����6#*R����z�6���u��C�gu����_A׷R����_u����Oe��?��?.e`�/�D����+뿃a��A���(b"9��ͧ�,�;9�,\wPV�%�[�'w	�'Ũߌ�8gt�K���Es��r+D���2BQF�Dr�V�ʅ��а��:��,�L�G5�i�.��{Q��?�oE���?��v��k�o@�`��:����������Z�4`���c�;�G����[��-.�/�����#r����c�{�09�O����颒�������[�A�\���g� @���3 �?�هg \�j�W���T��! o����YB�o6���Њd�/ѥ��!�F�)h�\��6˒�Xx#2�.��yy�`(����N<�{Qo�n���z�A�D��@ߍ���p��{z��� �i	�.\ꁝ�-�">~�z�Ƿ�Q��8$�Ŋ��
��T�5�=��e�h�.F��9ׅ���+w��/5."����Ox]6EUj��;��&;=t�@hL&Z[���LR�$�g��L�E����"䚡���H��j�N�69�o��G'�������h�_�E�:�?�|��H�e������E����z?�A1���:�?�>����)(��!ӯ�(��0��i������C�?��C���O��W�R��y>My��$�2So��!��yM�\Ƞ,͆��O��Ax�OY.$��h/���OC��G�(�J����u{�aY��CM�s��*���O���sc;$���Ĥ�_k ��4��g�*ȅ�lT�E�6{l�d�&�^��ݸ�����G�!���\yFm�qp�;ډ��]%�-��}/�p�������S
>���U?K�ߡ�����&0���@-�����a��$����tC�{��_5�_�:��U�����~���	����'h���������o ~��6���h��MA9'c&N��ʼ���J�%޻�˸1G~f����3���V6��y>2G��7��ǝj�Eޜ�V�vLLY�,[&�#c��6ZP{Z�#���ڛ�r4dVg6�4^kyS+�)�q7�%ְ5ӧ���Y�rma�BW�I��r����mG�;ƹ������
�t���ަk+T��ۡb��c�C�I�;�OeG�.;�j�d��4"��ַ'!�zG���|�6I�Bk3r�!w��H�,J����9O�V"����:�,d<��}��"�1ǩ��Z�e��:迋ڃ�+B9��w�+��������c�V�r���:���i��J���7���7��A�}��ۯ2� j	�������C��:���O_�PԢ���K�P������_�����j����Q�e�������C�~���(����'��/u�E�����������P5������8��*T��Q1����+������RP��p�
��_9�S����RP/��p��Q��h�	�� � ����#?�Z�?�������P��!�����j������I���ZH�C��(�����R ��� ��� ���?��P�m�W���e��C8D٨E�� �����R ��� ���Pm��@�A�c)����������_[�Ղ����8��Ԋ�a��tԡ����� ��0�������P��=��2P����>مP�W ���������p�Cy��c�E�h����@�˅���ـ#q"���N=4 H4�0��8c<��H�b��}�;��E���1��+���@^*��h��V�+�K���S*(h�]�ӌPTͻ]AK�&/}q{���qh(���jIaP4s���y~�;����Tw�E��F1$��*i�a��ås6ԙj�B��q%���h�$����!�|Sr�Զ�p
�<����ݓ����p�����P�����o������P�����P���\���_�/�:�?���W���ЩSc߳�Vc��Ⱦѝ�b{џ��/[X��?��^�?;\�2�&�k��n7W��� ���E�C�Qx�N-u�t&���b>IO
��ou��#��(��i�Y��2e@��^���w�;��%�����#������u������ �_���_����j�ЀU����a�����|���zO��7�'t�!!�����f�8�Bd���ke�Z�=k����Wp,���u �?"�:�ej͆t\r[��ړԏ�6F"S�ߎb��M���1��ht��#-Dڂ^�E��3"3�s܍�,�A���LW���v��啾f�=]:�:�o:-!ׅ�{a'DrK�����#o.�p�o7���q(H>��]'�u��,b�{����Ѳ�e���eST���w�����8��>�Su�5�Cd}�ܙu8p��t5>��xJ`��%*6���}c��x��1�[bٜmR�ٚ��}w~����4ܽ���?��E����3�������?��/u��0�A�'������?%���WmQ���q�'Q��/u�����$�(���s=!ӣ~(���1��y���(N��W���[���{��n�f���A�8�;�{�~ׁ�}�W��$޺����fi�+ώ�t�Q�^�
����?Y~�G���Y~�w�������_[��.D7�rp�.���5��sl���m!
^�VU��ꂐ_�Ά0�a��i#�WV_F����en'+�2�Ō��p�蚖�rѰS�[�51����b�r�d8W�U��1��]�����{�-Z���{r߼ɭ���\�\�&��k^��7�y�f���n���{b*Ef,��t'��h�vS�^��MnF�c�mR�E��i�,=Roۯ\��h� �ϻ��
XDv(�?0j:�͏�ܩ���©K�F�FB�4=!�N���\���,PWnJ��l�n0⬞��ɿ��wC-�u7��ߒP��c|
�i��|f�b$�q3"����$p3��Q����$��G0>P��h�Ma���P���~����`�������f|���~�|���n2��[oq;'��S�l��]!|����+V+�G��U����{�ٟ������������:�?�!�������?85F��M������A������nq�������g�=;���0:23��Yp��yv��_��^��z����1�o�m����j�!���ƺ�ܼ������~��|?���V�
��f�HwR�[��>9:jSn��5���v#^�}7��͋k?�T��'��3v6*��V'�մ3��~�G}���<��<_.ֱ�7��wfJC6f�)ɖW��Y���d>��ɲ�5����������z=�P;3�rܻ�(J�M3[/�<@��O���*E3S�a͹�	��*l��Mw�.:d3P���ܝUf���}����G�?��[
J��S�AH�,�3ǯ���|E1a8�}��<�c���]0e1
�p��<����'���������������_�M�S��O}9q�$\i�9�v����7O������e�U� �-��������~��c��2P�wQ{���W���{��_8᱖ �����!��:����1��������w�?�C�_
������������TUgm�nWf��,:����/�ptA��?t_���*����Gim�o!
ȷ�@�%[&tir6�ِ�gc�\S���=�r�ֹB>ں�u����+��忧�Nk����sR�����ܜԩs���Cz��V*�����[9��� uj��mw҉Τ3�f3q}���D��w���Zk�w]�u%���uNj�G�3�u����;z*��]k4�t]�o���j�t��9>�V{f4�{�Y�b9m�U:�[r�劘��?ݶZ�jx���)4����c�������q��Y�R7V<�oMֳ�F�k���^[�?^l��4���Vْ�6/Ju�����Bhj��1)uLy62��x5������*&-%�h�Y�Z?�z��ʀ)�u�ZIuG��e��8���j��I�.����\��O������7��dB�����W���m�/��?�#K��@�����2��/B�w&@�'�B�'���?�o��?��@.�����<�?���#c��Bp9#��E��D�a�?�����oP�꿃����y�/�W	�Y|����3$��ِ��/�C�ό�F�/���G�	�������J�/��f*�O�Q_; ���^�i�"�����u!����\��+�P��Y������J����CB��l��P��?�.����+㿐��	(�?H
A���m��B��� �##�����\������� ������0��_��ԅ@���m��B�a�9����\�������L��P��?@����W�?��O&���Bǆ�Ā���_.���R��2!����ȅ���Ȁ�������%����"P�+�F^`�����o��˃����Ȉ\���e�z����Qfh���V�6���V�Ě&_2)�����Z��eL�L�E��؏�[ݺ?=y��"w��C�6���;=e��Ex�:}���`W��ؔ��V�7�r�,IO��j]��XK��]��N�;u�dE?�)�Z�ƶ�͗�
�dG{�ݔ=!��4]�ݢ�:肸�Bbfk�6C�VXK2�*C�	���b���q�cתG��<s�����]����h�+���g��P7x��C��?с����0��������<�?������?�>qQ�����?��5�I˻Z�C���Hb1�(�e��q˶�Ӷ���rgO���_�:Z���`�э����fCM�"vX"�h�.�j��oՋ�mXù��5vy���|�TǮ6�Wr`R��
=	��ג���㿈@��ڽ����"�_�������/����/����؀Ʌ��r�_���f��G�����k��(����i=�0r�������M����+bM�ɔ��į�@q��`�r�M Alz�q�%I�ݟE�ݢ��ƚ>��uwR�K"}&V<.l����ة����$�M�Aj=z�\ks��u�]�6A��6�zE�6�l����ӯ��ya�h������d�]��]��OE�;���{Ex��$%N�� ;��YU+�c���{i�a/l>%��j�S(�tj9�����lԚ{�Lkl�,��fS�
��A����*aJ�t,�a�u�]��,�=btywุmȤ֮4����m������X��������v�`��������?�J�Y���,ȅ��W�x��,�L��^���}z@�A�Q�?M^��,ς�gR�O��P7�����\��+�?0��	����"�����G��̕���̈́<�?T�̞���{�?����=P��?B���%�ue��L@n��
�H�����\�?������?,���\���e�/������S���}��P�Ҿ=�#���*ߛps˸�����q�������ib��rW���a&�#M��^��;i������s��������nщ���x�ju~�I�Z�����be�Ì��yyC��Rѧ���!;3��08A���rf����i�������(M���h��s�/v%�Wӫ��#
��CK.H��G��m�>+�Z�[�e�:	�zޯ�L��3�uj�n6#���YMڒ��IV'��f5�������>v+E,D�\0k�0ۻce�2��4�}"8*�bu;���`�������n�[��۶�r��0���<���KȔ\��W�Q0��	P��A�/�����g`����ϋ��n����۶�r��,	������=` �Ʌ�������_����/�?�۱ר/"a�ri���As2����k����c�~�h�MomlF��4�����~��Pڇ�Zy�����E��T4��xOUg=��o*ڴEo�:_�!�)��+Q��>{�fq� h�v������Ʋ��#�s �4	��� `i��� �b!�	�=n��r���"�+�r�0e�U����taQ�{��'�zWRD6,oZr��#�rXa�)��A,�6u�+�ք�b}���n�&�ue����	���O���n����۶���E�J��"��G��2�Z��,N3�rI3�ER�-��9F�Xڢi�T6YʰH�'-�5L���r����1|���g&�m�O��φ��瀟�}�qK��t��'l$���Ҩ��'�^[�V5s���GoB��]0�@����OD��W�5&�X%^�vQ�Z��\�N%�.,OÎ9�z����,�T-+��>v�e7�����%�?��D��?]
u�8y����CG.����\��L�@�Mq��A���CǏ����n=^,kzGVEbNbb�h��r����֢�S�c'�n��?�/��p��}߯0���ˬ	)�c�c�:b'dq��uz@̏-��+>�jFmY7��zDg��q�Ckrp��ג���"������ y�oh� 0Br��_Ȁ�/����/������P�����<�,[�߲�Ʃ�gK������scw߱�@.��pK�!�y��)�G�, {^�e@ae�;m]墭�u���Պ�V���i��Z��Q�E%�S[Ec9+�ё���`���j�<�N���0�P��TiVhm��z)��ӗf��y�&��'>^�҈���օ8e�;��qS�:_ ��0`R��?a~�$��PWKUE҉ٶ�bN��w��1���(%g�)��Y�&��p�/�R��m��^ľ*(�T$�Օ��Ժ��eC�G��]�KN���qmώ-k`y�b��#��`��a�������Bo�gvw>�2=�8-�9����ő����>:�������Lb�}��4�������6]<�gZd�wO����/;����I��{A����H����#��w��_tHw���M\z�s�gSAN>&tB���E�.מ���?�_w�y���n��#J�u����LN�鏃�˃�?&w,��Z��ϛ�����y��>%Q�q�}��������q_��4����������q	]�7�zp"�sq�	�7�������F��^�O�Fs��=�~g��T��4���c䤯v��	=���?;W�$r��Ozd9�t<Z���39��	�����U�އw���s<��lx|����B������������;�����;����UrT��-�$��ݧ�;���|��H* �m��u�?��>���:y[�����|�n�^}�%�jy^?�f�6����	�<���Jvs\CK�Y��x�_�s]ǵ�u"o�������;�R���7�8P���p���k-H?��mt3��4���k����k��skrvg�=�O�y���L�M3 ���^:��~�7·���+���I�L�kaN��0#�X|n<�g�&��ɪ����)%-��"���Ɠڽ��N�����w�v��ȏ���I�	�0��څ_R�ûW5�2=�;��K����������>
                           ���#F�Q � 