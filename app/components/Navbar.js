import { ReactNode, useRef, useState } from 'react';
import {
  Box,
  Flex,
  Button,
  useColorModeValue,
  Stack,
  useColorMode,
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalCloseButton,
  ModalBody,
  FormControl,
  FormLabel,
  Input,
  ModalFooter,
  useDisclosure
} from '@chakra-ui/react';
import { MoonIcon, SunIcon } from '@chakra-ui/icons';
import { ethers } from 'ethers';
import { CORE_ABI, CORE_ADDRESS } from '../constants';

const walletProvider =  new ethers.providers.Web3Provider(window.ethereum);
const rpcProvider = new ethers.providers.JsonRpcProvider("https://8545-bravo1b9-solidmemory-sfly90y7ln7.ws-eu70.gitpod.io");
const walletSigner = walletProvider.getSigner();
const rpcSigner = rpcProvider.getSigner();
const privateKey = '0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e';
const wallet = new ethers.Wallet(privateKey, rpcProvider);
const coreContract = new ethers.Contract(CORE_ADDRESS, CORE_ABI, rpcProvider);

async function connect() {
  await walletProvider.send("eth_requestAccounts", []);
  console.log("Account:", await walletSigner.getAddress());
}

export default function Navbar() {
  const { colorMode, toggleColorMode } = useColorMode();
  const { isOpen, onOpen, onClose } = useDisclosure();

  const initialRef = useRef(null);
  const finalRef = useRef(null);

  const [cliqueName, setCliqueName] = useState("");
  const [privacySetting, setPrivacySetting] = useState(0);
  const [nftSetting, setNFTSetting] = useState(1);
  const [nftAddress, setNFTAddress] = useState("0x0000000000000000000000000000000000000000");

  const createClique = async () => {
    const coreContractWithWallet = coreContract.connect(walletSigner);
    const tx = await coreContractWithWallet.createClique(cliqueName, privacySetting, nftSetting, nftAddress);
    await tx.wait();
    console.log(tx);
  }

  return (
    <>
      <Box bg={useColorModeValue('gray.100', 'gray.900')} px={4}>
        <Flex h={16} alignItems={'center'} justifyContent={'space-between'}>
          <Box>Logo</Box>
          <Button onClick={onOpen}>Create Clique</Button>

          <Flex alignItems={'center'}>
            <Stack direction={'row'} spacing={7}>
              <Button onClick={toggleColorMode}>
                {colorMode === 'light' ? <MoonIcon /> : <SunIcon />}
              </Button>
              <Button onClick={connect}>Connect</Button>
            </Stack>
          </Flex>
        </Flex>
      </Box>

      <Modal
        initialFocusRef={initialRef}
        finalFocusRef={finalRef}
        isOpen={isOpen}
        onClose={onClose}
      >
        <ModalOverlay />
        <ModalContent>
          <ModalHeader>Create your clique</ModalHeader>
          <ModalCloseButton />
          <ModalBody pb={6}>
            <FormControl>
              <FormLabel>Clique name:</FormLabel>
              <Input type='text' ref={initialRef} placeholder='Your awesome clique name' 
              onChange={(e) => setCliqueName(e.target.value)}/>
            </FormControl>

            <FormControl mt={4}>
              <FormLabel>Privacy setting:</FormLabel>
              <Input type='number' ref={initialRef} placeholder='0' 
              onChange={(e) => setPrivacySetting(e.target.value)}/>
            </FormControl>

            <FormControl mt={4}>
              <FormLabel>NFT restriction:</FormLabel>
              <Input type='number' ref={initialRef} placeholder='1' 
              onChange={(e) => setNFTSetting(e.target.value)}/>
            </FormControl>

            {
              nftSetting == 0 ?
              <FormControl>
                <FormLabel>NFT address:</FormLabel>
                <Input type='text' ref={initialRef} placeholder='0x0000000000000000000000000000000000000000' 
                onChange={(e) => setNFTAddress(e.target.value)}/>
              </FormControl> :
              <span></span>
            }            
          </ModalBody>

          <ModalFooter>
            <Button colorScheme='blue' mr={3} 
            onClick={createClique}>
              Create
            </Button>
          </ModalFooter>
        </ModalContent>
      </Modal>
    </>
  );
}