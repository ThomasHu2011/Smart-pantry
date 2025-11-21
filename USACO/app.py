class ListNode:
    def __init__(self, data = 0, next = None):
        self.data = data
        self.next = next
    
def merge(l1: ListNode, l2: ListNode):
    result = ListNode()
    x = l1
    y = l2
    while x.next != None or y.next != None:
        if x > y:
            result.next = y.data
            y = y.next
        else:
            result.next = x.data
            x = x.next
        result = result.next
    return result.next 

    
    