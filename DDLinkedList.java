public class DDLinkedList {
    Node head;
    public class Node{
        int data;
        Node next;
        Node prev;
        Node(int data){
            this.data=data;
            this.next=null;
            this.prev=null;
        }
    }
    public void addFirst(int data){
        Node newNode=new Node(data);
        if(head==null){
            head=newNode;
            return;
        }
        newNode.next=head;
        head.prev=newNode;
        head=newNode;

    }
    public void addLast(int data){
        Node newNode=new Node(data);
        if(head==null){
            head=newNode;
            return;
        }
        Node currNode=head;
        while(currNode.next!=null){
            currNode=currNode.next;
        }
        currNode.next=newNode;
        newNode.prev=currNode;

    }
    public void printList(){
        
        if(head==null){
            System.out.println("Empty list");
            return;
        }
        Node currNode=head;
        while(currNode!=null){
            System.out.print(currNode.data + " <-> ");
            currNode=currNode.next;
        }
        System.out.println("null");
        

    }
    public void reverseList(){
        Node next=null;
        Node prev=null;
        Node curr=head;
        while(curr!=null){
            next=curr.next;
            curr.next=prev;
            curr.prev=next;
            prev=curr;
            curr=next;
        }
        head=prev;

    }


    public static void main(String args[]){
        DDLinkedList LL=new DDLinkedList();
        LL.printList();
        LL.addFirst(1);
        LL.addLast(2);
        LL.addLast(3);
        LL.addFirst(0);
        LL.printList();
        LL.reverseList();
        LL.printList();

        
    }
}
