import { useState, useEffect } from 'react';
import dynamic from 'next/dynamic';
import { ethers } from 'ethers';
import { 
  Box,
  Center,
  Text,
  Stack,
  Button,
  useColorModeValue,
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalFooter,
  ModalBody,
  ModalCloseButton,
  useDisclosure
} from '@chakra-ui/react';
import { CORE_ABI, CORE_ADDRESS, CLIQUE_ABI } from '../constants';

const Navbar = dynamic(() => import("../components/Navbar"), {
  ssr: false
});

const rpcProvider = new ethers.providers.JsonRpcProvider("https://8545-bravo1b9-solidmemory-sfly90y7ln7.ws-eu70.gitpod.io");
const rpcSigner = rpcProvider.getSigner();
const privateKey = '0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e';
const wallet = new ethers.Wallet(privateKey, rpcProvider);
const coreContract = new ethers.Contract(CORE_ADDRESS, CORE_ABI, rpcProvider);

export default function Home() {
  const { isOpen, onOpen, onClose } = useDisclosure();
  const [cliques, setCliques] = useState([]);
  const [clique, setClique] = useState("");
  const [cliqueAddress, setCliqueAddress] = useState("");

  let cliqueContract = new ethers.Contract("0xb0279Db6a2F1E01fbC8483FCCef0Be2bC6299cC3", CLIQUE_ABI, rpcProvider);

  useEffect(() => {
    fetchCliqueNames();
  }, []);

  const fetchCliqueNames = async () => {
    const result = await coreContract.getAllNames();
    console.log(result);
    setCliques(result);
    console.log(cliques);
  }

  const setCliqueAddr = async (_cliqueName) => {
    const result = coreContract.getCliqueAddress(_cliqueName);
    console.log(result);
    setCliqueAddress(result);
    console.log(cliqueAddress);
    console.log(cliqueContract);
  }

  const getCliqueAddr = (_cliqueName) => {
    onOpen();
    console.log(_cliqueName);
    setCliqueAddr(_cliqueName);
    setClique(_cliqueName);
    getCliqueName();
  }

  const getCliqueName = async () => {
    const name = await cliqueContract.getName();
    console.log(name);
  }

  return (
      <>
        <Navbar />
        <h1>Clique Test</h1>
        {
          cliques.map((clique, index) => (
            <Center py={6} key={index}>
              <Box
                maxW={'330px'}
                w={'full'}
                bg={useColorModeValue('white', 'gray.800')}
                boxShadow={'2xl'}
                rounded={'md'}
                overflow={'hidden'}>
                <Stack
                  textAlign={'center'}
                  p={6}
                  color={useColorModeValue('gray.800', 'white')}
                  align={'center'}>
                  <Text
                    fontSize={'sm'}
                    fontWeight={500}
                    bg={useColorModeValue('green.50', 'green.900')}
                    p={2}
                    px={3}
                    color={'green.500'}
                    rounded={'full'}>
                    NSFW
                  </Text>
                  <Stack direction={'row'} align={'center'} justify={'center'}>
                    <Text fontSize={'6xl'} fontWeight={800}>
                      {clique}
                    </Text>
                  </Stack>
                </Stack>

                <Box bg={useColorModeValue('gray.50', 'gray.900')} px={6} py={10}>
                  <Button
                    mt={10}
                    w={'full'}
                    bg={'green.400'}
                    color={'white'}
                    rounded={'xl'}
                    boxShadow={'0 5px 20px 0px rgb(72 187 120 / 43%)'}
                    _hover={{
                      bg: 'green.500',
                    }}
                    _focus={{
                      bg: 'green.500',
                    }}
                    onClick={() => getCliqueAddr(clique)}>
                    Find out more
                  </Button>
                </Box>
              </Box>
            </Center>
          ))
        }

        <Modal isOpen={isOpen} onClose={onClose}>
          <ModalOverlay />
          <ModalContent>
            <ModalHeader>c/{clique}</ModalHeader>
            <ModalCloseButton />
            <ModalBody>
              <p>This is a clique dedicated to {clique}</p>
            </ModalBody>

            <ModalFooter>
              <Button colorScheme='blue' mr={3} onClick={onClose}>
                Close
              </Button>
            </ModalFooter>
          </ModalContent>
        </Modal>
      </>
    );
};
